package com.teradata.benchmark.hadoop.sentiment;

/**
 * Enumeration representing all command line arguments supported/expected by
 * Classifier modules.
 * 
 * 
 * 
 * @author mmichalski
 *
 */

public enum ClassifierArg {
	evaluateFileLoc,modelFileLoc,outputFileLoc,categoryFieldPos,contentFieldPos,categories,
	evaluateFileDelimiter,outputFileDelimiter,sampleRows,outputInFields,regexpReplace,
	inputFileFormat,outputFileFormat,debug,compress;
}
