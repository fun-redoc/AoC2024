package de.rsh.aoc;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.math.BigInteger;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AOC202XBase {
    @FunctionalInterface
    public static interface SolutionFunction<I,O,E extends Throwable> {
        O apply(I in) throws E, IOException;
    }
     static String fileNameFromArgv(String[] argv) {
        String filename = null;
        for (int i = 0; i < argv.length; i++) {
            if ("-f".equals(argv[i]) && i + 1 < argv.length) {
                filename = argv[i + 1];
                break;
            }
        }
        return filename;
    }

    static void errExit(String message) {
        System.err.println(message);
        System.exit(1);
    }

    static List<BigInteger> getNumbersFromLine(String line, String startingWith) {
        ArrayList<BigInteger> res = new ArrayList<>();
        if (line.startsWith(startingWith)) {
            String regex = "\\b+\\d+\\b*";
            // Compile the regex pattern
            Pattern pattern = Pattern.compile(regex);
            // Create a matcher for the input string
            Matcher matcher = pattern.matcher(line);
            // Find and print all matches
            for (long i = 0; matcher.find(); i++) {
                res.add(new BigInteger(matcher.group()));
            }
        }
        return res;
    }

    public static String solveWithFile(String[] argv, SolutionFunction<BufferedReader, String, ParseException> solution) {
        String res = null;
        var filename = AOC202XBase.fileNameFromArgv(argv);
        if (filename == null) {
            AOC202XBase.errExit("No filename provided with the -f argument.\n");
        }

        assert filename != null;
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            res = solution.apply(br);
        } catch (IOException | ParseException e) {
            e.printStackTrace();
            AOC202XBase.errExit("\n");
        }
        return res;
    }
}
