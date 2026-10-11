/**
 * @author Rajesh Ediga
 * @description Structured logging for ComponentHub without sensitive record payloads.
 */
public with sharing class CH_LoggingService {
    public enum Level { INFO, WARN, ERROR }

    public static void info(String source, String message) {
        write(Level.INFO, source, message, null);
    }

    public static void warn(String source, String message) {
        write(Level.WARN, source, message, null);
    }

    public static void error(String source, String message, Exception ex) {
        write(Level.ERROR, source, message, ex);
    }

    private static void write(Level level, String source, String message, Exception ex) {
        String safeSource = String.isBlank(source) ? 'ComponentHub' : source.trim();
        String safeMessage = String.isBlank(message) ? 'No message' : message.trim();
        String detail = ex == null ? '' : ' | ' + ex.getTypeName() + ': ' + ex.getMessage();
        System.debug(LoggingLevel.ERROR, '[' + level.name() + '][' + safeSource + '] ' + safeMessage + detail);
    }
}
