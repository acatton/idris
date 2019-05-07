module Main

import System

%default covering

ttimpTests : List String
ttimpTests 
    = ["test001", "test002", "test003",
       "perf001", "perf002", "perf003"]

chdir : String -> IO Bool
chdir dir 
    = do ok <- foreign FFI_C "chdir" (String -> IO Int) dir
         pure (ok == 0)

fail : String -> IO ()
fail err 
    = do putStrLn err
         exitWith (ExitFailure 1)

runTest : String -> String -> String -> IO Bool
runTest dir prog test
    = do chdir (dir ++ "/" ++ test)
         putStr $ dir ++ "/" ++ test ++ ": "
         system $ "sh ./run " ++ prog ++ " > output"
         Right out <- readFile "output"
               | Left err => do print err
                                pure False
         Right exp <- readFile "expected"
               | Left err => do print err
                                pure False
         if (out == exp)
            then putStrLn "success"
            else putStrLn "FAILURE"
         chdir "../.."
         pure (out == exp)

main : IO ()
main
    = do [_, ttimp] <- getArgs
              | _ => do putStrLn "Usage: runtests [ttimp path]"
         ttimps <- traverse (runTest "ttimp" ttimp) ttimpTests
--          blods <- traverse (runTest "blodwen" blodwen) blodwenTests
         if (any not ttimps)
            then exitWith (ExitFailure 1)
            else exitWith ExitSuccess
