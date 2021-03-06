Feature: Parsing a pgn file

    Scenario Outline: Parse a single tag_pair pgn header
        Given a pgn file with only a header of the tag pairs <tag_pairs>
         When we parse it
         Then we can access a TagPair of k <tp_k>, v <tp_v>

        Examples: Tag Pairs
            | tag_pairs                  | tp_k  | tp_v        |
            | [Event "Let's Play!"]      | Event | Let's Play! |
            | [Event\n"Let's Play!"]     | Event | Let's Play! |
            | [\nEvent\n"Let's Play!"]   | Event | Let's Play! |
            | [\nEvent\n"Let's Play!"\n] | Event | Let's Play! |
            | [Site "Chess.com"]         | Site  | Chess.com   |


    Scenario Outline: Parse a multi tag_pair pgn header
        Given a pgn file with only a header of the tag pairs <tag_pairs>
         When we parse it
         Then we can access a fully populated TagPairs dict <tp_res>

        Examples: Tag Pairs
            | tag_pairs                                                     | tp_res        |
            | [Event "Let's Play!"]\n[Site "Chess.com"]                     | TEST_TP_2_RES |
            | [Event\n"Let's Play!"]\n[Site "Chess.com"]                    | TEST_TP_2_RES |
            | [Event "Let's Play!"] [Site "Chess.com"]                      | TEST_TP_2_RES |
            | [Event "Let's Play!"][Site "Chess.com"]                       | TEST_TP_2_RES |
            | [Event "Let's Play!"]\n[Site "Chess.com"] [Date "2018.12.13"] | TEST_TP_3_RES |


    Scenario Outline: Parse a multi tag_pair pgn header in order
        Given a pgn file with only a header of the tag pairs <tag_pairs>
         When we parse it
         Then we can string a TagPairs dict in order <tp_res>

        Examples: Tag Pairs
            | tag_pairs                                                                                     | tp_res            |
            | [Event "Let's Play!"]\n[Site "Chess.com"]\n[Date "2018.12.13"]                                | TEST_TP_3_RES_ORD |
            | [Event "Let's Play!"]\n[Site "Chess.com"]\n[Custom "xyz"]                                     | TEST_TP_4_RES_ORD |
            | [Event "Let's Play!"]\n[Site "Chess.com"]\n[Custom "xyz"]\n[Custom2 "xyz2"]\n[Custom3 "xyz3"] | TEST_TP_5_RES_ORD |


    Scenario Outline: Parse a pgn containing only movetext
        Given a pgn file with only movetext <movetext>
         When we parse it
         Then we can access the moves node containing an array of correct Move objects with SAN's <SANW> <SANB>

        Examples: Movetext
            | movetext             | SANW    | SANB    |
            | 1. e4 e5             | e4      | e5      |
            | 1.e4 e5              | e4      | e5      |
            | 1. e4 e5\n2. d4 d5   | e4,d4   | e5,d5   | 
            | 1. e4 e5\n2. Nf3 Nc6 | e4,Nf3  | e5,Nc6  | 
            | 1. e4 e5\n 2. d4 d5  | e4,d4   | e5,d5   |
            | 1.e4 e5\n 2.d4 d5    | e4,d4   | e5,d5   |
            | 1. e4 e5 2.\nd4 d5   | e4,d4   | e5,d5   |
            | 12. Nxd5 Bxd5        | Nxd5    | Bxd5    |
            | 12. exd5 cxd5        | exd5    | cxd5    |
            | 9. a8=Q axb8=R       | a8=Q    | axb8=R  |
            | 9. a8+ axb8=R#       | a8+     | axb8=R# |
            | 9. O-O O-O-O         | O-O     | O-O-O   |
            | 9. Ncxd5 Nce5        | Ncxd5   | Nce5    |
            | 9. N3xd5 N6e5        | N3xd5   | N6e5    |
            | 9. Nc3xd5 Nc6e5      | Nc3xd5  | Nc6e5   |
            | 1. e4                | e4      | NONE    |
            | 1...e5               | NONE    | e5      |
            | 1... e5              | NONE    | e5      |
            | 1... e5 2. d4        | NONE,d4 | e5,NONE |


    Scenario Outline: Parse movetext with variations
        Given a pgn file with only movetext <movetext>
         When we parse it
         Then we can access the variations <vs>

        Examples: variations
            | movetext                    | vs                 |
            | 1. e4 (1. d4)               | 1. d4              |
            | 1...e5 (1...d5)             | 1...d5             |
            | 1. e4 (1. d4 d5 2. c4 Nf6)  | 1. d4 d5 2. c4 Nf6 |
            | 1. e4 (1. d4 d5) (1. c4 e5) | 1. d4 d5,1. c4 e5  |


    Scenario Outline: Parse a comment
        Given a pgn file with only movetext <movetext>
         When we parse it
         Then we can access the comment and moves <SANW> <COMMW> <SANB> <COMMB> <COMMM>

        Examples: Movetext comment
            | movetext                                                | SANW   | COMMW  | SANB | COMMB | COMMM        |
            | 1. e4 {white} e5 {black}                                | e4     | white  | e5   | black | NONE         |
            | 1. e4 {white} e5 {black} {move comment}                 | e4     | white  | e5   | black | move comment |
            | 1. e4 e5 {black}                                        | e4     | NONE   | e5   | black | NONE         |
            | 1. e4 {white} e5                                        | e4     | white  | e5   | NONE  | NONE         |
            | 1. e4 { } e5                                            | e4     | SPACE  | e5   | NONE  | NONE         |
            | 1. e4 {\n} e5                                           | e4     | \n     | e5   | NONE  | NONE         |
            | 1. d4 { [%clk 0:03:00] } Nc6 { [%clk 0:03:00] } { A40 } | d4     | CLK    | Nc6  | CLK   | A40          |


    Scenario Outline: Parse a full pgn file
        Given the pgn file <f>
         When we parse it
         Then we should have a full Game that can be stringified to equal its input <f>

        Examples: PGNs
            | f           |
            | lcuser1.pgn |
            | cc1.pgn     |
            | cc4.pgn     |
            | cbnag.pgn   |
            | cbsply.pgn  |
            | cbvar.pgn   |
            | cblarge.pgn |
