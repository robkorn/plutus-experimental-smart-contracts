module NaiveLottery where

import qualified Language.PlutusTx            as PlutusTx
import qualified Language.PlutusTx.Prelude    as P
import qualified Language.PlutusTx.Builtins   as Builtins
import           Ledger
import           Ledger.Validation
import           Wallet
import           Playground.Contract



lotteryValidator :: ValidatorScript
lotteryValidator = ValidatorScript $ Ledger.fromCompiledCode $ $$(PlutusTx.compile
  [||
    \(ticket :: [Int]) (winningNums :: [Int]) (p :: PendingTx') ->
      let

        isNumWinner :: Int -> Bool
        isNumWinner n = $$(P.foldr) (\i acc -> $$(P.or) acc (Builtins.equalsInteger i n)) False winningNums

        isWinner :: Bool
        isWinner = $$(P.foldr) (\i acc -> $$(P.and) acc (isNumWinner i)) True ticket
      in
        if isWinner
        then ()
        else $$(P.error) ($$(P.traceH) "Not a winning ticket" ())
  ||])


lotAddress :: Address'
lotAddress = Ledger.scriptAddress lotteryValidator

startGame :: Int -> Int -> Int -> Value -> MockWallet ()
startGame n1 n2 n3 val = let nums = [n1, n2, n3]
    in payToScript_ lotAddress val $ DataScript $ Ledger.lifted nums

submitTicket :: Int -> Int -> Int -> MockWallet ()
submitTicket n1 n2 n3 = let nums = [n1, n2, n3]
    in collectFromScript lotteryValidator $ RedeemerScript $ Ledger.lifted nums

watchSCAddress :: MockWallet ()
watchSCAddress = startWatching lotAddress


$(mkFunction 'startGame)
$(mkFunction 'submitTicket)
$(mkFunction 'watchSCAddress)
