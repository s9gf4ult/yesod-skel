module Helper.Import
       ( module Import
       , HasSettings(..)
       , Handler
       , Form
       ) where

import ClassyPrelude.Yesod   as Import

import Settings              as Import
import Settings.StaticFiles  as Import
import Yesod.Core.Types      as Import (loggerSet)
import Yesod.Default.Config2 as Import

class HasSettings a where
    getSettings :: a -> AppSettings

type Handler m =
    ( MonadHandler m
    , HasSettings (HandlerSite m)
    )

-- | A convenient synonym for creating forms.
type Form app x =
    (RenderMessage app FormMessage)
    => Html -> MForm (HandlerT app IO) (FormResult x, WidgetT app IO ())
