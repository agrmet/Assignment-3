-- DO NOT MODIFY THE FOLLOWING LINES

module Huffman(HuffmanTree, characterCounts, huffmanTree, codeTable, encode, compress, decompress) where
import Debug.Trace
import Table
import PriorityQueue

import Test.HUnit

{- a bit code (of a character or string) is represented by a list of Booleans
   INVARIANT:
     the bit code is a concatenation of (0 or more) valid code words for some Huffman tree
 -}
type BitCode = [Bool]

-- END OF DO NOT MODIFY ZONE

--------------------------------------------------------------------------------

{- characterCounts s
   RETURNS: a table that maps each character that occurs in s to the number of
         times the character occurs in s
   EXAMPLES:
 -}
characterCounts :: String -> Table Char Int
characterCounts s = characterCountsAux s Table.empty

characterCountsAux :: String -> Table Char Int -> Table Char Int
characterCountsAux "" t = t
characterCountsAux (x:xs) t = characterCountsAux xs $ Table.insert t x (Table.iterate t (\acc (k,v) -> if k == x then acc + v else acc) 1)

-- modify and add comments as needed
data HuffmanTree = Leaf Char Int | Node HuffmanTree Int HuffmanTree deriving (Show, Eq)

{- huffmanTree t
   PRE:  t maps each key to a positive value
   RETURNS: a Huffman tree based on the character counts in t
   EXAMPLES:
 -}
huffmanTree :: Table Char Int -> HuffmanTree
huffmanTree = undefined


{- codeTable h
   RETURNS: a table that maps each character in h to its Huffman code
   EXAMPLES:
 -}
codeTable :: HuffmanTree -> Table Char BitCode
codeTable = undefined

{- encode h s
   PRE: All characters in s appear in h
   RETURNS: the concatenation of the characters of s encoded using the Huffman code table of h.
   EXAMPLES:
 -}
encode :: HuffmanTree -> String -> BitCode
encode (Leaf k v) s = []
encode h [] = []
encode h s = encode' h (head s) [] ++ encode h (tail s)
  where
    encode' (Leaf k v) c acc
      | k == c = acc
      | otherwise = []
    encode' (Node l _ r) c acc = (encode' l c acc ++ [False]) ++ (encode' r c acc ++ [True])

{- compress s
   RETURNS: (a Huffman tree based on s, the Huffman coding of s under this tree)
   EXAMPLES:
 -}
compress :: String -> (HuffmanTree, BitCode)
compress s = (huffmanTree (characterCounts s), encode (huffmanTree (characterCounts s)) s)

{- decompress h bits
   PRE:  bits is a concatenation of valid Huffman code words for h
   RETURNS: the decoding of bits under h
   EXAMPLES: decompress h [False,False,False] == "e"
             h == Fig. 4 huffmantree in PDF
-}
decompress :: HuffmanTree -> BitCode -> String
-- VARIANT: 
decompress h [] = []
decompress h bits = decompress' h bits h
  where
    decompress' (Leaf k v) b acc = k : decompress acc b
    decompress' (Node l _ r) b acc
      | head b = decompress' r (tail b) acc
      | otherwise = decompress' l (tail b) acc

--------------------------------------------------------------------------------
-- Test Cases
-- You may add your own test cases here:
-- Follow the pattern and/or read about HUnit on the interwebs.
--------------------------------------------------------------------------------

-- characterCounts
test1 = TestCase $ assertEqual "characterCounts"
            (Just 7) (Table.lookup (characterCounts "this is an example of a huffman tree") ' ')

-- codeTable
-- while the precise code for ' ' may vary, its length (for the given example string) should always be 3 bits
test2 = TestCase $ assertEqual "codeTable"
            3 (maybe (-1) length (Table.lookup (codeTable (huffmanTree (characterCounts "this is an example of a huffman tree"))) ' '))

-- compress
-- while the precise code for the given example string may vary, its length should always be 135 bits
test3 = TestCase $ assertEqual "compress"
            135 (length (snd (compress "this is an example of a huffman tree")))

-- decompress
test4 =
    let s = "this is an example of a huffman tree"
    in
      TestCase $ assertEqual ("decompress \"" ++ s ++ "\"")
        s (let (h, bits) = compress s in decompress h bits)

test5 =
    let s = "xxx"
    in
      TestCase $ assertEqual ("decompress \"" ++ s ++ "\"")
        s (let (h, bits) = compress s in decompress h bits)

test6 =
    let s = ""
    in
      TestCase $ assertEqual ("decompress \"" ++ s ++ "\"")
        s (let (h, bits) = compress s in decompress h bits)

-- for running all the tests
runtests = runTestTT $ TestList [test1, test2, test3, test4, test5, test6]
