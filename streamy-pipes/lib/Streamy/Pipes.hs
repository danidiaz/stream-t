module Streamy.Pipes (
          Stream
        , yield
        , toList
        , toList_
        , each
        , chain
        , effects
        , Streamy.Pipes.concat
        , for
        , Streamy.Pipes.repeat
        , Streamy.Pipes.repeatM
        , Streamy.Pipes.take
        , Streamy.Pipes.map
        , Streamy.Pipes.mapM
        , Streamy.Pipes.mapM_
        , Streamy.Pipes.drop
    ) where

import Pipes (Proxy,X,(>->))
import qualified Pipes as P
import qualified Pipes.Prelude as PP

type Stream = Proxy X () ()

yield :: Monad m => o -> Stream o m ()
yield = P.yield

each :: (Monad m, Foldable f) => f a -> Stream a m ()
each = P.each

chain :: Monad m => (o -> m ()) -> Stream o m r -> Stream o m r
chain action producer = producer >-> PP.chain action

effects :: Monad m => Stream o m r -> m r
effects producer = P.runEffect $ producer >-> PP.drain   

toList :: Monad m => Stream a m r -> m ([a],r)
toList = PP.toListM'

toList_ :: Monad m => Stream a m () -> m [a]
toList_ = PP.toListM

concat :: (Monad m, Foldable f) => Stream (f a) m r -> Stream a m r
concat producer = P.for producer each

for :: Monad m => Stream a m r -> (a -> Stream b m ()) -> Stream b m r
for = P.for

repeat :: Monad m => a -> Stream a m r
repeat = PP.repeatM . return

repeatM :: Monad m => m a -> Stream a m r
repeatM = PP.repeatM

take :: Monad m => Int -> Stream o m r -> Stream o m () 
take i producer = P.void producer >-> PP.take i

map :: Monad m => (a -> b) -> Stream a m r -> Stream b m r 
map f producer = producer >-> PP.map f

mapM :: Monad m => (a -> m b) -> Stream a m r -> Stream b m r
mapM f producer = producer >-> PP.mapM f

mapM_ :: Monad m => (a -> m b) -> Stream a m r -> m r
mapM_ f producer = P.runEffect $ producer >-> PP.mapM_ (P.void . f)

drop :: Monad m => Int -> Stream a m r -> Stream a m r
drop i producer = producer >-> PP.drop i

