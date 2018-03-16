module Main where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Monoid (mempty)
import Data.Int (ceil)

import Control.Coroutine (Producer, Consumer, runProcess, pullFrom, await)
import Control.Coroutine.Aff (produce')

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Aff (Aff, makeAff, launchAff_)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Except (runExcept)
import Control.Monad.Rec.Class (forever)
import Control.Monad.State (StateT, lift, modify, get, runStateT)

import DOM (DOM)
import DOM.HTML (window)
import DOM.HTML.Types (HTMLElement, htmlElementToElement)
import DOM.HTML.Window (requestAnimationFrame)
import DOM.HTML.HTMLElement (getBoundingClientRect)
import DOM.Node.Types (elementToEventTarget)
import DOM.Event.EventTarget (addEventListener, eventListener)
import DOM.Event.MouseEvent (MouseEvent, eventToMouseEvent, clientX, clientY)
import DOM.Event.Types (Event, EventType(..), EventTarget)

import Graphics.Canvas (CANVAS, CanvasElement, Context2D, clearRect, getCanvasElementById, getContext2D, strokeText)
import Unsafe.Coerce as U

type BigCanvasState = { canvas :: CanvasElement, context :: Context2D, x :: Int, y :: Int }
type BigCanvas e = StateT BigCanvasState 
            (Aff (canvas :: CANVAS, dom :: DOM, console :: CONSOLE, avar :: AVAR | e))

canvasToHTMLElement :: CanvasElement -> HTMLElement
canvasToHTMLElement = U.unsafeCoerce

canvasToEventTarget :: CanvasElement -> EventTarget
canvasToEventTarget = elementToEventTarget <<< htmlElementToElement <<< canvasToHTMLElement 

createState :: CanvasElement -> Context2D -> BigCanvasState
createState canvas ctx = { canvas: canvas, context: ctx, x: 0, y:0 }

type EventHandler = forall e. Event -> BigCanvas e Unit
type MouseEventHandler = forall e. MouseEvent -> BigCanvas e Unit

data BigCanvasEvent 
        = EMouseDown Event
        | EMouseMove Event
        | EDraw 

withMouseEvent :: forall e. Event -> (MouseEvent -> BigCanvas e Unit) -> BigCanvas e Unit
withMouseEvent e f = do 
    case runExcept $ eventToMouseEvent e of
        (Right me) -> f me
        _          -> liftEff $ log "not a mouse event"

onEvent ::  forall e. BigCanvasEvent -> BigCanvas e Unit
onEvent (EMouseDown _) = pure unit 

onEvent (EMouseMove e) =  do
    s <- get
    rect <- liftEff $ getBoundingClientRect (canvasToHTMLElement s.canvas)
    withMouseEvent e (\me -> modify \s -> s { x = clientX me - ceil rect.left, y = clientY me - ceil rect.top })

onEvent (EDraw) = do
    s <- get
    _ <- liftEff $ clearRect s.context {x: 0.0, y: 0.0, w: 100.0, h: 100.0}
    _ <- liftEff $ strokeText s.context (show s.x <> ", " <> show s.y) 10.0 10.0 
    pure unit

setupEventLoop :: forall e. EventTarget -> BigCanvas e Unit
setupEventLoop target = runProcess $ consumer `pullFrom` producer
    where
    producer :: Producer BigCanvasEvent (BigCanvas e) Unit
    producer = produce' \emit -> do
        addEventListener (EventType "mousemove") 
                (eventListener (emit <<< Left <<< EMouseMove)) false target  
        addEventListener (EventType "mousedown") 
                (eventListener (emit <<< Left <<< EMouseDown)) false target 

        launchAff_ (forever $ waitForAnimationFrame *> liftEff (emit (Left EDraw)))

    consumer :: Consumer BigCanvasEvent (BigCanvas e) Unit
    consumer = forever $ lift <<< onEvent =<< await

waitForAnimationFrame :: forall e. Aff (dom :: DOM | e) Unit
waitForAnimationFrame = 
    makeAff \emit -> do 
        win <- window
        requestAnimationFrame (emit $ Right unit) win $> mempty

main :: forall e. Eff (canvas :: CANVAS, dom :: DOM, console :: CONSOLE, avar :: AVAR | e) Unit
main = do
    mbCanvas <- getCanvasElementById "canvas"
    case mbCanvas of
        Nothing -> log "no canvas found"
        Just canvas -> do
            ctx <- getContext2D canvas
            launchAff_ $ runStateT 
                (setupEventLoop $ canvasToEventTarget canvas) (createState canvas ctx)


