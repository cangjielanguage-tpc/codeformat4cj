package codeformat

class SqlFormat <: BaseLanguage {

    let KeyWorldList:Array<String> =[
   "ABORT", "ABS", "ABSENT", "ABSOLUTE", "ACCESS", "ACCESSIBLE", "ACCORDING",
  "ACOS", "ACCOUNT", "ACTION", "ADA", "ADD ",  "AFTER", "AGGREGATE",
  "ALGORITHM", "ALL", "ALLOCATE", "ALSO", "ALTER ", "ALWAYS", "ANALYSE", "ANALYZE",
  "AND ", "ANY", "ANY_VALUE", "ARE", "ARRAY", "ARRAY_AGG", "ARRAY_MAX_CARDINALITY",
  "AS ", " ASC", "ASENSITIVE", "ASIN", "ASSERTION", "ASSIGNMENT", "ASYMMETRIC",
   "ATAN", "ATOMIC", "ATTACH", "ATTRIBUTE", "ATTRIBUTES", "AUTO_INCREMENT","AUTHENTICATION",
  "AUTHORIZATION", "AVG(", "AVG_ROW_LENGTH", "BACKWARD", "BASE64",
  "BEFORE", "BEGIN", "BEGIN_FRAME", "BEGIN_PARTITION", "BERNOULLI", "BETWEEN","BETWEEN ",
  "BIGINT", "BINARY", "BINLOG", "BIT", "BIT_LENGTH", "BLOB", "BLOCK", "BLOCKED","BACKUP DATABASE",
  "BOM", "BOOL", "BOOLEAN", "BOTH", "BREADTH", "BTRIM", "BTREE", "BUCKETS", "BULK","BREAK ",
  "BY", "BYTE",  "CACHE", "CALL", "CALLED", "CARDINALITY", "CASCADE",
  "CASCADED", "CASE", "CAST", "CATALOG", "CATALOG_NAME", "CEIL", "CEILING",
  "CHAIN", "CHAINING", "CHALLENGE_RESPONSE", "CHANGE", "CHANGED", "CHANNEL",
  "CHAR", "CHARACTER", "CHARACTERISTICS", "CHARACTERS", "CHARACTER_LENGTH",
  "CHARACTER_SET_CATALOG", "CHARACTER_SET_NAME", "CHARACTER_SET_SCHEMA",
  "CHAR_LENGTH", "CHARSET", "CHECK ","CHECK("," CHECKDB", "CHECKPOINT", "CHECKSUM", "CLASS",
  "CLASSIFIER", "CLASS_ORIGIN", "CIPHER", "CLIENT", "CLONE", "CLOSE", "CLUSTER","CLUSTERED",
  "COALESCE", "COBOL", "COLLATE", "COLLATION", "COLLATION_CATALOG",
  "COLLATION_NAME", "COLLATION_SCHEMA", "COLLECT", "COLUMN ", "COLUMNS",
  "COLUMN_FORMAT", "COLUMN_NAME", "COMMAND_FUNCTION", "COMMAND_FUNCTION_CODE",
  "COMMENT", "COMMENTS", "COMMIT", "COMMITTED", "COMPACT", "COMPLETION",
  "COMPONENT", "COMPRESSION", "COMPUTE", "CONCAT","CONCURRENT", "CONCURRENTLY",
  "CONDITION", "CONDITIONAL", "CONDITION_NUMBER", "CONFIGURATION", "CONFLICT",
  "CONNECT", "CONNECTION", "CONNECTION_NAME", "CONSTRAINT", "CONSTRAINTS",
  "CONSTRAINT_CATALOG", "CONSTRAINT_NAME", "CONSTRAINT_SCHEMA", "CONSTRUCTOR",
  "CONTAINS", "CONTAINSTABLE", "CONTENT", "CONTINUE", "CONTROL", "CONVERSION",
  "CONVERT", "COPARTITION", "COPY", "CORR", "CORRESPONDING", "COS", "COSH",
  "COST", "COUNT", "COVAR_POP", "COVAR_SAMP", "CREATE ", "CREATE TYPE", "CROSS ", "CSV", "CUBE",
  "CUME_DIST", "CURRENT", "CURRENT_CATALOG", "CURRENT_DATE","CURDATE","CURRENT ROW",
  "CURRENT_DEFAULT_TRANSFORM_GROUP", "CURRENT_PATH", "CURRENT_ROLE", "CURRENT_ROW",
  "CURRENT_SCHEMA", "CURRENT_TIME", "CURRENT_TIMESTAMP","CURTIME",
  "CURRENT_TRANSFORM_GROUP_FOR_TYPE", "CURRENT_USER", " CURSOR ", "CURSOR_NAME",
  "CYCLE",   "DATABASE", "DATABASES", "DATALINK", "DATAFILE", " DATE "," DATETIME",
  "DATETIME_INTERVAL_CODE", "DATETIME_INTERVAL_PRECISION", " DAY", "DAY_HOUR",
  "DAY_MICROSECOND", "DAY_MINUTE", "DAY_SECOND", " DB ", "DBCC", "DEALLOCATE", "DEC","DENY",
  "DECFLOAT", "DECIMAL", "DECLARE", "DEFAULT", "DEFAULTS", "DEFERRABLE", "DEFERRED",
  "DEFINE", "DEFINED", "DEFINER", "DEFINITION", "DEGREE", "DELETE ", "DELIMITER",
  "DELIMITERS", "DENSE_RANK", "DEPENDS", "DEPTH", "DEREF", "DERIVED", " DESC"," DELAY ",
  "DESCRIBE", "DESCRIPTOR", "DETACH", "DETERMINISTIC", "DIAGNOSTICS",
  "DICTIONARY", "DISABLE", "DISCARD", "DISCONNECT", "DISK", "DISPATCH",
  "DISTINCT ", "DISTINCTROW", "DIV", "DLNEWCOPY", "DLPREVIOUSCOPY", "DLURLCOMPLETE",
  "DLURLCOMPLETEONLY", "DLURLCOMPLETEWRITE", "DLURLPATH", "DLURLPATHONLY",
  "DLURLPATHWRITE", "DLURLSCHEME", "DLURLSERVER", "DLVALUE", "DO", "DOCUMENT",
  "DOMAIN", "DOUBLE", "DROP ", "DUAL", "DUMPFILE", "DUPLICATE", "DYNAMIC",
  "DYNAMIC_FUNCTION", "DYNAMIC_FUNCTION_CODE",  "EACH", "ELEMENT", "ELSE",
  "ELSEIF", "EMPTY", "ENABLE", "ENCODING", "ENCRYPTED", " END ","END;","END WHILE","END LOOP", "END-EXEC",
  "END_FRAME", "END_PARTITION", "ENFORCED", "ENGINE", "ENGINES","END IF",
  "ENGINE_ATTRIBUTE", "ENUM", "EQUALS", "ERROR", "ERRORS", "ESCAPE", "EVENT",
  "EVENTS", "EVERY", "EXCEPT", "EXCEPTION", "EXCLUDE", "EXCLUDING", "EXCLUSIVE",
  "EXEC", "EXECUTE", "EXISTS", "EXIT", "EXP", "EXPLAIN", "EXPANSION", "EXPIRE",
  "EXPRESSION", "EXTENSION", "EXTERNAL", "EXTRACT",  "FALSE", "FAMILY",
  "FAILED_LOGIN_ATTEMPTS", "FAST", "FAULTS", "FETCH", "FIELDS", "FILE",
  "FILE_BLOCK_SIZE", "FILTER", "FINAL", "FINALIZE", "FINISH", "FIRST","FLUSH ",
  "FIRST_VALUE", "FILLFACTOR",  "FLOAT", "FLOAT4", "FLOAT8", "FLOOR",
  "FOLLOWING", "FOLLOWS", "FOR", "FORCE", "FOREIGN","FOREIGN KEY", "FORMAT", "FORTRAN",
  "FORWARD", "FOUND", "FRAME_ROW", "FREE", "FREEZE", "FROM", "FREETEXT",
  "FREETEXTTABLE", "FS", "FULFILL", "FULL ", "FULLTEXT", "FUNCTION", "FUNCTIONS",
  "FUSION",  "GENERAL", "GENERATE", "GENERATED", " GET ", "GET_FORMAT",
  "GET_MASTER_PUBLIC_KEY", "GET_SOURCE_PUBLIC_KEY", "GLOBAL", "GO ", "GOTO",
  "GRANT", "GRANTED", "GREATEST", "GROUP","GROUP BY", "GROUPING", "GROUPS",
  "GROUP_REPLICATION", "GTID_ONLY",  "HANDLER", "HASH", "HAVING ", "HEADER",
  "HELP", "HEX", "HIERARCHY", "HIGH_PRIORITY", "HISTOGRAM",  "HOLD",
  "HOLDLOCK", "HOST", "HOSTS", "HOUR", "HOUR_MICROSECOND", "HOUR_MINUTE",
  "HOUR_SECOND",  "IDENTIFIED", "IDENTITY", "IDENTITY_INSERT",
  "IDENTITYCOL", "IF ","IFNULL","IGNORE", "IGNORE_SERVER_IDS", "ILIKE", "IMMEDIATE",
  "IMMEDIATELY", "IMMUTABLE", "IMPLEMENTATION", "IMPLICIT", "IMPORT", " IN",
  "INCLUDE", "INCLUDING", "INACTIVE", "INCREMENT", "INDENT", "INDEX", "INDEXES",
  "INDICATOR", "INHERIT", "INHERITS", "INITIAL", "INITIAL_SIZE", "INITIALLY",
  "INITIATE", "INLINE", "INNER ", "INOUT", "INPUT", "INSENSITIVE", "INSERT ",
  "INSERT_METHOD", "INSTANCE", "INSTANTIABLE", "INSTEAD", "INT", "INT1", "INT2",
  "INT3", "INT4", "INT8", "INTEGER", "INTEGRITY", "INTERSECT", "INTERSECTION",
  "INTERVAL", "INTO ", "INVISIBLE", "INVOKER", "IO", "IO_AFTER_GTIDS",
  "IO_BEFORE_GTIDS", "IO_THREAD", "IPC", "IS ", "ISNULL", "ISOLATION", "ISSUER",
  "ITERATE",  "JOIN ", "JSON", "JSONB", "JSON_ARRAY", "JSON_ARRAYAGG", "JSON_EXISTS",
  "JSON_OBJECT", "JSON_OBJECTAGG", "JSON_QUERY", "JSON_SCALAR", "JSON_SERIALIZE",
  "JSON_TABLE", "JSON_TABLE_PRIMITIVE", "JSON_VALUE",  "KEEP", " KEY",
  "KEY_BLOCK_SIZE", "KEY_MEMBER", "KEY_TYPE", "KEYRING", "KEYS", "KILL",
  "LABEL",  "LANGUAGE","LANGUAGE SQL", "LARGE", "LAST", "LAST_VALUE", "LATERAL", "LEAD",
  "LEADING", "LEAKPROOF", "LEAST", "LEFT ", "LEAVE", "LEAVES","LENGTH", "LESS",
  "LIBRARY", "LIKE ", "LIKE_REGEX", "LIMIT ", "LINEAR", "LINES", "LINK", "LISTAGG",
  "LISTEN", "LN", "LOAD", "LOCAL", "LOCALTIME", "LOCALTIMESTAMP", "LOCATION",
  "LOCATOR", "LOCK", "UNLOCK ", "LOCKED", "LOCKS", "LOG10", "LOGGED", "LOGFILE",
  "LOGS", "LONG", "LONGBLOB", "LONGTEXT", "LOOP", "LOWER", "LOW_PRIORITY", "LPAD",
  "LTRIM",  "MAP", "MAPPING", "MATCH", "MATCHED", "MATCHES", "MATCH_NUMBER",
  "MATCH_RECOGNIZE", "MATERIALIZED", "MAX(", "MAXVALUE", "MASTER",
  "MASTER_AUTO_POSITION", "MASTER_BIND", "MASTER_COMPRESSION_ALGORITHMS",
  "MASTER_CONNECT_RETRY", "MASTER_DELAY", "MASTER_HEARTBEAT_PERIOD", "MASTER_HOST",
  "MASTER_LOG_FILE", "MASTER_LOG_POS", "MASTER_PASSWORD", "MASTER_PORT",
  "MASTER_PUBLIC_KEY_PATH", "MASTER_RETRY_COUNT", "MASTER_SERVER_ID", "MASTER_SSL",
  "MASTER_SSL_CA", "MASTER_SSL_CAPATH", "MASTER_SSL_CERT", "MASTER_SSL_CIPHER",
  "MASTER_SSL_CRL", "MASTER_SSL_CRLPATH", "MASTER_SSL_KEY",
  "MASTER_SSL_VERIFY_SERVER_CERT", "MASTER_TLS_CIPHERSUITES",
  "MASTER_TLS_VERSION", "MASTER_USER", "MASTER_ZSTD_COMPRESSION_LEVEL", "MAX_CONNECTIONS_PER_HOUR",
  "MAX_QUERIES_PER_HOUR", "MAX_ROWS", "MAX_SIZE", "MAX_UPDATES_PER_HOUR",
  "MAX_USER_CONNECTIONS", "MEASURES", "MEMBER", "MEDIUM", "MEDIUMBLOB",
  "MEDIUMINT", "MEDIUMTEXT", "MEMORY", "MERGE", "MERGE_ACTION", "MESSAGE_LENGTH",
  "MESSAGE_OCTET_LENGTH", "MESSAGE_TEXT", "METHOD", "MICROSECOND", "MIDDLEINT",
  "MIGRATE", "MIN(", "MINUTE", "MINUTE_MICROSECOND", "MINUTE_SECOND", "MIN_ROWS",
  "MINVALUE", " MOD ", " MODE", "MODIFIES", "MODIFY ", "MODULE", "MONTH", "MORE",
  "MOVE", "MULTILINESTRING", "MULTIPOINT", "MULTIPOLYGON", "MULTISET", "MUMPS",
  "MUTEX", "MYSQL_ERRNO",  "NAMES", "NAMESPACE", "NATIONAL",
  "NATURAL", "NCHAR", "NCLOB", "NDB", "NDBCLUSTER", "NESTED", "NESTING",
  "NETWORK_NAMESPACE", "NEW", "NEXT","NEXTVAL", "NFC", "NFD", "NFKC", "NFKD", "NIL", "NO",
  "NOCHECK", "NODEGROUP", "NONE", "NONCLUSTERED", "NORMALIZE", "NORMALIZED",
  " NOT","NOT NULL", "NOTHING", "NOTIFY", "NOTNULL", "NOW","NOWAIT", "NO_WAIT",
  "NO_WRITE_TO_BINLOG", "NTH_VALUE", "NTILE", " NULL","NULL)", "NULLABLE", "NULLIF",
  "NULLS", "NULL_ORDERING", "NUMBER", "NUMERIC", "NVARCHAR", "OBJECT",
  "OBJECTS", "OCCURRENCE", "OCCURRENCES_REGEX", "OCTETS", "OCTET_LENGTH", "OF",
  "OFF", "OFFSETS", "OFFSET", "OIDS", " OLD ", "OMIT", "ON "," ON;", "ONLY", "OPEN",
  "OPENDATASOURCE", "OPENQUERY", "OPENROWSET", "OPENXML", "OPERATOR", "OPTION",
  "OPTIONAL", "OPTIONALLY", "OPTIONS", "OR ", "ORDER BY", "ORDERING", "ORDINALITY",
  "ORGANIZATION", "OTHERS", "OUT", "OUTER ", "OUTFILE", "OUTPUT", "OVER", "OPTIMIZE TABLE",
  "OVERFLOW", "OVERLAPS", "OVERLAY", "OVERRIDING", "OWNED", "OWNER",  "PAD",
  "PARALLEL", "PARAMETER", "PARAMETER_MODE", "PARAMETER_NAME",
  "PARAMETER_ORDINAL_POSITION", "PARAMETER_SPECIFIC_CATALOG",
  "PARAMETER_SPECIFIC_NAME", "PARAMETER_SPECIFIC_SCHEMA", "PARAMETERS",
  "PARSER", "PARTIAL", "PARTITION","PARTITION BY", "PARTITIONING", "PARTITIONS", "PASCAL",
  "PASS", "PASSING", "PASSTHROUGH", "PASSWORD", "PASSWORD_LOCK_TIME", "PAST",
  " PATH ", "PATTERN", "PER", "PERCENT", "PERCENTILE_CONT", "PERCENTILE_DISC",
  "PERCENT_RANK", "PERIOD", "PERMISSION", "PERMUTE", "PERSIST", "PERSIST_ONLY",
  "PHASE", "PIPE", "PLACING", "PLAN", "PLANS", "PLI", "PLUGIN", "PLUGINS",
  "PLUGIN_DIR", "POINT", "POLYGON", "PORT", "PORTION", "POSITION",
  "POSITION_REGEX", "POWER", "PRECEDES", "PRECEDING", "PRECISION", "PREPARE","PIVOT(","PIVOT ",
  "PREPARED", "PRESERVE", "PREV", "PRIMARY","PRIMARY KEY", "PRIOR", "PRIVATE", "PRIVILEGES",
  "PROCEDURAL", "PROCEDURE", "PROCEDURES", "PROCESS", "PROCESSLIST", "PROFILE",
  "PROFILES", "PROGRAM", "PRUNE", "PTF", "PUBLIC ", "PUBLICATION", "PURGE",
  "QUARTER", "QUERY", "QUICK", "QUOTE", "QUOTES", "RANGE", "RANK", "READ","PRINT",
  "READS", "READTEXT", "REAL", "REASSIGN", "REBUILD", "RECOVER", "RECOVERY",
  "RECURSIVE", "REF", "REFERENCE", "REFERENCES", "REFERENCING", "REFRESH",
  "REGR_AVGX", "REGR_AVGY", "REGR_COUNT", "REGR_INTERCEPT", "REGR_R2",
  "REGR_SLOPE", "REGR_SXX", "REGR_SXY", "REGR_SYY", "REINDEX", "RELATIVE",
  "RELEASE", "RELOAD", "RENAME", "REORGANIZE", "REPAIR", "REPEAT", "REPEATABLE",
  "REPLACE", "REPLICA", "REPLICAS", "REPLICATE_DO_DB", "REPLICATE_DO_TABLE",
  "REPLICATE_IGNORE_DB", "REPLICATE_IGNORE_TABLE", "REPLICATE_REWRITE_DB",
  "REPLICATE_WILD_DO_TABLE", "REPLICATE_WILD_IGNORE_TABLE", "REPLICATION",
  "REQUIRE", "REQUIRE_ROW_FORMAT", "RESET", "RESIGNAL", "RESPECT", "RESTART",
  "RESTORE", "RESTRICT", "RESULT", "RETURN", "RETURNED_CARDINALITY",
  "RETURNED_LENGTH", "RETURNED_OCTET_LENGTH", "RETURNED_SQLSTATE", "RETURNING",
  "RETURNS", "REVERT", "REVOKE", "RIGHT ", "RLIKE",  "ROLLBACK", "ROLLUP",
  "ROUND","ROUTINE", "ROUTINES", "ROUTINE_CATALOG", "ROUTINE_NAME", "ROUTINE_SCHEMA",
  "ROW", "ROW_COUNT", "ROW_FORMAT", "ROW_GUIDCOL", "ROW_NUMBER", "ROWS",
  "RPAD", "RTRIM", "RULE", "RUNNING",  "SAVE", "SAVEPOINT", "SCALAR",
  "SCALE", "SCHEDULE", " SCHEMA ","SCHEMA:", "SCHEMAS", "SCHEMA_NAME", "SCOPE",
  "SCOPE_CATALOG", "SCOPE_NAME", "SCOPE_SCHEMA", "SCROLL", "SEARCH ", "SECOND",
  "SECONDARY", "SECONDARY_ENGINE", "SECONDARY_ENGINE_ATTRIBUTE",
  "SECONDARY_LOAD", "SECONDARY_UNLOAD", "SECOND_MICROSECOND", "SECTION",
  "SECURITY", "SECURITYAUDIT", "SEEK", "SELECT", "SELECTIVE", "SELF",
  "SEMANTICKEYPHRASETABLE", "SEMANTICSIMILARITYDETAILSTABLE","SCHEMABINDING",
  "SEMANTICSIMILARITYTABLE", "SENSITIVE", "SEQUENCE", "SEQUENCES",
  "SERIAL", "SERIALIZABLE", "SERVER", "SERVER_NAME", "SESSION", "SESSION_USER",
  "SET ", "SETOF", "SETS", "SHARE", "SHUTDOWN", "SHOW", "SIGNAL", "SIGNED",
  "SIMILAR", "SIMPLE", "SIN", "SINH", "SIZE", "SKIP", "SLAVE", "SLOW", "SMALLINT",
  "SNAPSHOT", "SOCKET", "SOME", "SONAME", "SOUNDS", "SOURCE",
  "SOURCE_AUTO_POSITION", "SOURCE_BIND", "SOURCE_COMPRESSION_ALGORITHMS",
  "SOURCE_CONNECT_RETRY", "SOURCE_DELAY", "SOURCE_HEARTBEAT_PERIOD",
  "SOURCE_HOST", "SOURCE_LOG_FILE", "SOURCE_LOG_POS", "SOURCE_PASSWORD",
  "SOURCE_PORT", "SOURCE_PUBLIC_KEY_PATH", "SOURCE_RETRY_COUNT", "SOURCE_SSL",
  "SOURCE_SSL_CA", "SOURCE_SSL_CAPATH", "SOURCE_SSL_CERT", "SOURCE_SSL_CIPHER",
  "SOURCE_SSL_CRL", "SOURCE_SSL_CRLPATH", "SOURCE_SSL_KEY",
  "SOURCE_SSL_VERIFY_SERVER_CERT", "SOURCE_TLS_CIPHERSUITES",
  "SOURCE_TLS_VERSION", "SOURCE_USER", "SOURCE_ZSTD_COMPRESSION_LEVEL", "SPACE",
  "SPECIFIC", "SPECIFICTYPE", "SPECIFIC_NAME", "SPATIAL", " SQL ", "SQLCODE",
  "SQLERROR", "SQLEXCEPTION", "SQLSTATE", "SQLWARNING", "SQL_AFTER_GTIDS",
  "SQL_AFTER_MTS_GAPS", "SQL_BEFORE_GTIDS", "SQL_BIG_RESULT", "SQL_BUFFER_RESULT",
  "SQL_CACHE", "SQL_CALC_FOUND_ROWS", "SQL_NO_CACHE", "SQL_SMALL_RESULT",
  "SQL_THREAD", "SQL_TSI_DAY", "SQL_TSI_HOUR", "SQL_TSI_MINUTE", "SQL_TSI_MONTH",
  "SQL_TSI_QUARTER", "SQL_TSI_SECOND", "SQL_TSI_WEEK", "SQL_TSI_YEAR", "SQRT",
  "SRID", "SSL", "STACKED", "START", "STARTING", "STARTS", "STATE", "STATEMENT",
  "STATIC", "STATISTICS", "STDDEV_POP", "STDDEV_SAMP", "STDIN", "STDOUT",
  "STORAGE", "STORED", "STRAIGHT_JOIN", "STREAM", "STRICT", "STRING", "STRIP",
  "STRUCTURE", "STYLE", "SUBCLASS_ORIGIN", "SUBMULTISET", "SUBSCRIPTION",
  "SUBSET", "SUBPARTITION", "SUBPARTITIONS", "SUBSTRING", "SUBSTRING_REGEX",
  "SUCCEEDS", "SUM(", "SUPER", "SUPPORT", "SUSPEND", "SWAPS", "SWITCHES",
  "SYMMETRIC", "SYSID", "SYSTEM", "SYSTEM_TIME", "SYSTEM_USER",  "TABLE ",
  "TABLES", "TABLESAMPLE", "TABLESPACE", "TABLE_CHECKSUM", "TABLE_NAME", "TAN",
  "TANH", "TARGET", "TEMP", "TEMPLATE", "TEMPORARY", "TERMINATED", "TEXT", "THAN",
  "THEN", "THREAD_PRIORITY", "THROUGH", "TIES",  "TIMESTAMP",
  "TIMESTAMPADD", "TIMESTAMPDIFF", "TIMEZONE_HOUR", "TIMEZONE_MINUTE", "TINYBLOB",
  "TINYINT", "TINYTEXT", "TLS", "TO ", "TOKEN", "TOP", "TOP_LEVEL_COUNT",
  "TRAN", "TRAILING", "TRANSACTION", "TRANSACTIONS_COMMITTED",
  "TRANSACTIONS_ROLLED_BACK", "TRANSACTION_ACTIVE", "TRANSFORM", "TRANSFORMS",
  "TRANSLATE", "TRANSLATE_REGEX", "TRANSLATION", "TREAT", "TRIGGER",
  "TRIGGER_CATALOG", "TRIGGER_NAME", "TRIGGER_SCHEMA", "TRIGGERS", "TRIM",
  "TRIM_ARRAY", "TRUE", "TRUNCATE", "TRUSTED","TYPES", "TRY_CONVERT","USE ",
  "TSEQUAL", "UESCAPE", "UNBOUNDED", "UNCOMMITTED", "UNCONDITIONAL", "UNDER",
  "UNENCRYPTED", "UNION ","UNION ALL", "UNIQUE", "UNKNOWN", "UNLINK", "UNLISTEN", "UNLOGGED",
  "UNMATCHED", "UNNAMED", "UNNEST", "UNREGISTER", "UNPIVOT ","UNPIVOT(", "UNTIL", "UNTYPED",
  "UNSIGNED", "UPDATE ", "UPDATETEXT", "UPPER", "UPGRADE", "URI", "URL", "USAGE",
  "USER_DEFINED_TYPE_CATALOG", "USER_DEFINED_TYPE_CODE",
  "USER_DEFINED_TYPE_NAME", "USER_DEFINED_TYPE_SCHEMA", "USER_RESOURCES",
  "USE_FRM", "USING", "UTC_DATE", "UTC_TIME", "UTC_TIMESTAMP", "VACUUM",
  "VALID", "VALIDATE", "VALIDATION", "VALIDATOR", "VALUE", "VALUE_OF", "VALUES",
  "VARBINARY", "VARCHAR", "VARCHARACTER", "VARIABLES", "VARIADIC", "VARYING",
  "VAR_POP", "VAR_SAMP", "VCPU", "VERBOSE", "VERSION", "VERSIONING", " VIEW ",
  "VIEWS", "VIRTUAL", "VISIBLE", "VOLATILE", "WAIT", "WAITFOR", "WARNINGS",
  "WEEK", "WEIGHT_STRING", "WHEN", "WHENEVER", "WHERE ", "WHILE", "WHITESPACE",
  "WIDTH_BUCKET", "WINDOW", "WITH", "WITHIN", "WITHOUT", "WORK", "WRAPPER",
  "WRITE", "WRITETEXT",  "X509", "XA", "XID", "XML", "XMLAGG",
  "XMLATTRIBUTES", "XMLBINARY", "XMLCAST", "XMLCOMMENT", "XMLCONCAT",
  "XMLDECLARATION", "XMLDOCUMENT", "XMLELEMENT", "XMLEXISTS", "XMLFOREST",
  "XMLITERATE", "XMLNAMESPACES", "XMLPARSE", "XMLPI", "XMLQUERY", "XMLROOT",
  "XMLSCHEMA", "XMLSERIALIZE", "XMLTABLE", "XMLTEXT", "XMLVALIDATE", "XOR",
  "YEAR", "YEAR_MONTH", "YES", "ZEROFILL", "ZONE", "TIME ZONE"
]

    let arrayListFlagBegin: ArrayList<FlagBean> = ArrayList<FlagBean>()
    let arrayListFlagCase: ArrayList<FlagBean> = ArrayList<FlagBean>()
    let arrayListFlagIF: ArrayList<FlagBean> = ArrayList<FlagBean>()

    private func matchKw(chars: Array<Rune>, idx: Int64, kw: String): Bool {
        let kwLen = kw.size
        if (idx < kwLen - 1) { return false }
        let kwR = kw.toRuneArray()
        for (i in 0..kwLen) {
            if (chars[idx - kwLen + 1 + i].toAsciiLowerCase() != kwR[i].toAsciiLowerCase()) {
                return false
            }
        }
        return true
    }

    private func createLineBean(stateBean: StateBean, offset: Int64): LineBean {
        let lb = LineBean()
        let codeChars = stateBean.codeChars.getOrThrow()
        let start = stateBean.perLineStartIndex
        let safeEnd = min(stateBean.currentIndex, codeChars.size - 1)
        lb.codeLine = String(codeChars.slice(start, safeEnd - start + 1 - offset))
        return lb
    }

    private func setCommonFields(lb: LineBean, sb: StateBean): Unit {
        lb.smallBracketDouble = sb.smallBracketDouble
        lb.middleBracketDouble = sb.middleBracketDouble
        lb.sharpBracketDouble = sb.sharpBracketDouble
        lb.isInString = sb.isInString
        lb.isInMacro = sb.isInMacro
        lb.isInFor = sb.isInFor
    }

    private func finishLine(lb: LineBean, sb: StateBean, offset: Int64, lastChar: Rune, advance!: Bool = true): Unit {
        setCommonFields(lb, sb)
        sb.linesList.add(lb)
        sb.perLineOutput = StringBuilder()
        sb.isLineStart = false
        sb.perLineStartIndex = sb.currentIndex + 1 - offset
        sb.lastChar = lastChar
        if (advance) { sb.currentIndex++ }
    }

    private func makeSimpleLine(sb: StateBean, offset: Int64, lastChar: Rune): LineBean {
        let lb = createLineBean(sb, offset)
        lb.indentLevel = sb.indentLevel
        finishLine(lb, sb, offset, lastChar)
        return lb
    }

    public override func dealWithNewLine(stateBean: StateBean): Unit {
    }

    public override func dealWithLeftBigBracket(stateBean: StateBean): Unit {
    }

    public override func dealWithRightBigBracket(stateBean: StateBean): Unit {
    }

    public override func dealWithSingleLineComment(stateBean: StateBean, perStr: String): Unit {
        stateBean.isInSinglelineComment = true
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]

        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2
        while (beforeSpaceIndex >= 0 && stateBean.codeChars.getOrThrow()[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }
        var tempSingleLineAfterChangLine: Bool = false
        if (beforeSpaceIndex < 0) {
            tempSingleLineAfterChangLine = true
        } else {
            let char: Rune = stateBean.codeChars.getOrThrow()[beforeSpaceIndex]
            if (char == r'\n') {
                tempSingleLineAfterChangLine = true
            } else {
                tempSingleLineAfterChangLine = false
            }
        }

        if (perStr.size > 0) {
            tempSingleLineAfterChangLine = true
        }

        while (currChar != r'\n') {
            if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                break
            }
            stateBean.currentIndex++
            currChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
            stateBean.perLineOutput.append(currChar)
        }
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineBean.codeLine = perStr + lineCode
        lineBean.indentLevel = stateBean.indentLevel
        setCommonFields(lineBean, stateBean)
        lineBean.isInSinglelineComment = stateBean.isInSinglelineComment
        lineBean.singleLineWhiteSpace = beforeSpaceCount
        lineBean.singlelineCommentisAfterChangeLine = tempSingleLineAfterChangLine
        stateBean.linesList.add(lineBean)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInSinglelineComment = false
    }

    public override func dealWithMultiLineComment(stateBean: StateBean, perStr: String): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        stateBean.isInMultilineComment = true
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = notNullChar[stateBean.currentIndex]
        var lastChar: Rune = r'/'

        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2
        while (beforeSpaceIndex >= 0 && notNullChar[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }
        var tempMultiLineAfterChangLine: Bool = false
        if (beforeSpaceIndex < 0) {
            tempMultiLineAfterChangLine = true
        } else {
            let char: Rune = notNullChar[beforeSpaceIndex]
            if (char == r'\n') {
                tempMultiLineAfterChangLine = true
            } else {
                tempMultiLineAfterChangLine = false
            }
        }

        if (perStr.size > 0) {
            tempMultiLineAfterChangLine = true
        }

        if (notNullChar.size > stateBean.currentIndex + 2) {
            stateBean.currentIndex += 2
            let newcurrentIndex = stateBean.currentIndex
            lastChar = notNullChar[newcurrentIndex - 1]
            currChar = notNullChar[newcurrentIndex]
            stateBean.perLineOutput.append(lastChar)
            while (!(lastChar == r'*' && currChar == r'/')) {
                if (stateBean.currentIndex == notNullChar.size - 1) {
                    break
                }
                stateBean.currentIndex++
                stateBean.perLineOutput.append(currChar)
                currChar = notNullChar[stateBean.currentIndex]
                lastChar = notNullChar[stateBean.currentIndex - 1]
            }
        } else {
            if (notNullChar.size > stateBean.currentIndex + 1) {
                stateBean.currentIndex++
            }
        }

        let lineEndIndex: Int64 = stateBean.currentIndex
        var lineCodeAll: String = String(notNullChar.slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineCodeAll = perStr + lineCodeAll
        let lineCodeList: Array<String> = lineCodeAll.split("\n")
        for (index in 0..lineCodeList.size) {
            let lineBean: LineBean = LineBean()
            lineBean.codeLine = lineCodeList[index]
            if (index == 0) {
                lineBean.isFirstMultiCommentLine = true
                lineBean.multilineCommentisAfterChangeLine = tempMultiLineAfterChangLine
            }
            lineBean.indentLevel = stateBean.indentLevel
            setCommonFields(lineBean, stateBean)
            lineBean.isInMultilineComment = stateBean.isInMultilineComment
            stateBean.linesList.add(lineBean)
            stateBean.perLineOutput = StringBuilder()
        }
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInMultilineComment = false
    }

    public override func dealWithMacro(stateBean: StateBean): Unit {
    }

    public override func dealWithAccessPublic(stateBean: StateBean): Bool {
        return false
    }

    public override func dealWithAccessPrivate(stateBean: StateBean): Bool {
        return false
    }

    public override func dealWithAccessProtected(stateBean: StateBean): Bool {
        return false
    }

    public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        if ((currChar == r'\'') && !stateBean.isInString) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            return
        }
        if (stateBean.isInString && currChar == stateBean.stringQuote && lastChar != r'\\') {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
        if (stateBean.isInString && currChar == r'\n') {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
    }

    private func dealWithKeyWorldUpper(keyword:String,currentIndex:Int64,notNullChar: Array<Rune>){
        let charList = keyword.toRuneArray()
        for(i in 0..charList.size){
            notNullChar[currentIndex-charList.size+1+i] = charList[i].toAsciiUpperCase()
        }
    }

    public override func dealWithFor(stateBean: StateBean): Unit {
        if (stateBean.currentIndex >= 3) {
            let chars = stateBean.codeChars.getOrThrow()
            let idx = stateBean.currentIndex
            if (matchKw(chars, idx, " for")) {
                stateBean.isInFor = true
            }
        }
    }

    public override func dealWithSemicolon(stateBean: StateBean): Unit {
        if(stateBean.isInEndRepeat){
            stateBean.isInEndRepeat = false
            if(stateBean.indentLevel > 0){
                stateBean.indentLevel--
            }
        }
        makeSimpleLine(stateBean, 0, r';')
    }

    public func dealWithSqlValues(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "values")) {
            stateBean.isInValues = true
            dealWithInSqlValues(stateBean)
        }
    }

    public func dealWithSqlRenameTable(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 12 && matchKw(chars, idx, "rename table ")) {
            dealWithInSqlRenameTable(stateBean)
        }
    }

    public func dealWithSqlWith(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 4 && matchKw(chars, idx, "with ")) {
            if(stateBean.isInCreateView){
                dealWithInSqlWith(stateBean)
            }
        }
    }

    public func dealWithSqlBegin(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "begin ")) {
            stateBean.isInBegin = true
            dealWithInSqlBegin(stateBean)
        }
    }

    public func dealWithSqlCase(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 4 && matchKw(chars, idx, "case ")) {
            stateBean.isInCase = true
            dealWithInSqlCase(stateBean)
        }
    }

    public func dealWithSqlIf(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 3 && matchKw(chars, idx, " if ")) {
            if(stateBean.isInBegin){
                stateBean.isInIfFirst = true
                stateBean.isInIf = true
                dealWithInSqlIf(stateBean)
            }
        }
    }

    public func dealWithSqlWhen(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 4 && matchKw(chars, idx, "when ")) {
            dealWithInSqlWhen(stateBean)
        }
    }

    public func dealWithSqlThen(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 4 && matchKw(chars, idx, "then ")) {
            if(stateBean.isInIfFirst){
                dealWithInSqlThen(stateBean)
            }
        }
    }

    public func dealWithSqlElse(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, " else ")) {
            stateBean.isInElseFirst = true
            stateBean.isInElse = true
            dealWithInSqlElse(stateBean)
        }
    }

    public func dealWithSqlBreak(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "break ")) {
            dealWithInSqlBreak(stateBean)
        }
    }

    public func dealWithSqlContinue(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 8 && matchKw(chars, idx, " continue")) {
            stateBean.isInContinue = true
            dealWithInSqlContinue(stateBean)
        }
    }

    public func dealWithSqlEnd(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 4 && (matchKw(chars, idx, " end;") || matchKw(chars, idx, ";end;"))) {
            dealWithInSqlEnd(stateBean)
        }
    }

    public func dealWithSqlEndIF(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7 && matchKw(chars, idx, " end if;")) {
            dealWithInSqlEndIF(stateBean)
        }
    }

    public func dealWithSqlEndAs(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7 && matchKw(chars, idx, " end as ")) {
            stateBean.isInEndAs = true
            dealWithInSqlEndAs(stateBean)
        }
    }

    public func dealWithSqlPivot(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5) {
            if (matchKw(chars, idx, "pivot(")) {
                dealWithInSqlPivot(stateBean, 1)
            } else if (matchKw(chars, idx, "pivot ")) {
                dealWithInSqlPivot(stateBean, 0)
            }
        }
    }

    public func dealWithSqlUnpivot(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7) {
            if (matchKw(chars, idx, "unpivot(")) {
                stateBean.isInUnpivot = true
                dealWithInSqlUnpivot(stateBean, 1)
            } else if (matchKw(chars, idx, "unpivot ")) {
                stateBean.isInUnpivot = true
                dealWithInSqlUnpivot(stateBean, 0)
            }
        }
    }

    public func dealWithSqlKeyWord(stateBean:StateBean,keyWord:String):Unit{
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if(currentIndex >= keyWord.size - 1){
            var matchLetter:Bool = true
            for(i in 0..keyWord.size){
                if(!(notNullChar[currentIndex + 1 - keyWord.size + i].toAsciiLowerCase() == keyWord.toRuneArray()[i].toAsciiLowerCase())){
                    matchLetter = false
                    break
                }
            }
            if(matchLetter){
                dealWithKeyWorldUpper(keyWord,currentIndex,notNullChar)
            }
        }
    }

    public func dealWithSqlUnion(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "union ")) {
            dealWithSqlInUnion(stateBean)
        }
    }

    public func dealWithSqlIntersect(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 9 && matchKw(chars, idx, "intersect ")) {
            dealWithSqlInIntersect(stateBean)
        }
    }

    public func dealWithSqlExcept(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 6 && matchKw(chars, idx, "except ")) {
            dealWithSqlInExcept(stateBean)
        }
    }

    public func dealWithSqlUnionAll(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 8 && matchKw(chars, idx, "union all")) {
            stateBean.isInUnionAll = true
            dealWithSqlInUnionAll(stateBean)
        }
    }

    public func dealWithSqlJoin(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 4 && matchKw(chars, idx, "join ")) {
            stateBean.isInJoin = true
            dealWithInSqlJoin(stateBean)
        }
    }

    public func dealWithSqlAs(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 3 && matchKw(chars, idx, " as ")) {
            if(stateBean.isInCreateView || stateBean.isInReturns || stateBean.isInInsteadOf ||
                stateBean.isInCreateProcedure || stateBean.isInCreateFunction){
                stateBean.isInCreateView = false
                stateBean.isInReturns = false
                stateBean.isInInsteadOf = false
                stateBean.isInCreateProcedure = false
                stateBean.isInCreateFunction = false
                dealWithInSqlAs(stateBean)
            }
        }
    }

    public func dealWithSqlAsTwo(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "as $$ ")) {
            stateBean.isInAsTwo = true
        }
    }

    public func dealWithSqlTwoLanguage(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 11 && matchKw(chars, idx, "$$ language ")) {
            dealWithInSqlTwoLanguage(stateBean)
        }
    }

    public func dealWithSqlLanguage(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 9 && matchKw(chars, idx, " language ")) {
            dealWithInSqlLanguage(stateBean)
        }
    }

    public func dealWithSqlDo(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 3 && matchKw(chars, idx, " do ")) {
            stateBean.isInDo = true
            if(stateBean.isInWhile){
                return
            }
            dealWithInSqlDo(stateBean)
        }
    }

    public func dealWithSqlWhile(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "while ")) {
            stateBean.isInWhile = true
        }
    }

    public func dealWithSqlLoop(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 4 && matchKw(chars, idx, "loop ")) {
            dealWithInSqlLoop(stateBean)
        }
    }

    public func dealWithSqlRepeat(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 6 && matchKw(chars, idx, "repeat ")) {
            dealWithInSqlRepeat(stateBean)
        }
    }

    public func dealWithSqlBefore(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 6 && matchKw(chars, idx, "before ")) {
            dealWithInSqlBefore(stateBean)
        }
    }

    public func dealWithSqlForEach(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 8 && matchKw(chars, idx, "for each ")) {
            dealWithInSqlForEach(stateBean)
        }
    }

    public func dealWithSqlExecuteFunction(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 16 && matchKw(chars, idx, "execute function ")) {
            dealWithInSqlExecuteFunction(stateBean)
        }
    }

    public func dealWithSqlReturn(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 6 && matchKw(chars, idx, "return ")) {
            dealWithInSqlReturn(stateBean)
        }
    }

    public func dealWithSqlReturns(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7 && matchKw(chars, idx, "returns ")) {
            stateBean.isInReturns = true
            dealWithInSqlReturns(stateBean)
        }
    }

    public func dealWithSqlInsteadOf(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 10 && matchKw(chars, idx, "instead of ")) {
            stateBean.isInInsteadOf = true
            dealWithInSqlInsteadOf(stateBean)
        }
    }

    public func dealWithSqlEndRepeat(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 9 && matchKw(chars, idx, "end repeat")) {
            stateBean.isInEndRepeat = true
            dealWithInSqlEndRepeat(stateBean)
        }
    }

    public func dealWithSqlCharacter(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 9 && matchKw(chars, idx, "character ")) {
            stateBean.isInCharacter = true
        }
    }

    public func dealWithSqlOver(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 4 && matchKw(chars, idx, "over(")) {
            stateBean.isInOver = true
        }
    }

    public func dealWithSqlCursor(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 6 && matchKw(chars, idx, "cursor ")) {
            stateBean.isInCursor = true
        }
    }

    public func dealWithSqlDeclare(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7 && matchKw(chars, idx, "declare ")) {
            stateBean.isInDeclare = true
        }
    }

    public func dealWithSqlCrossJoin(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 10 && matchKw(chars, idx, "cross join ")) {
            stateBean.isInJoin = true
            stateBean.isInMultiJoin = true
            dealWithInSqlCrossJoin(stateBean)
        }
    }

    public func dealWithSqlInnerJoin(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 10 && matchKw(chars, idx, "inner join ")) {
            stateBean.isInJoin = true
            stateBean.isInMultiJoin = true
            dealWithInSqlInnerJoin(stateBean)
        }
    }

    public func dealWithSqlLeftJoin(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 9 && matchKw(chars, idx, "left join ")) {
            stateBean.isInJoin = true
            stateBean.isInMultiJoin = true
            dealWithInSqlLeftJoin(stateBean)
        }
    }

    public func dealWithSqlRightJoin(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 10 && matchKw(chars, idx, "right join ")) {
            stateBean.isInJoin = true
            stateBean.isInMultiJoin = true
            dealWithInSqlRightJoin(stateBean)
        }
    }

    public func dealWithSqlFullOuterJoin(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 15 && matchKw(chars, idx, "full outer join ")) {
            stateBean.isInJoin = true
            stateBean.isInMultiJoin = true
            dealWithInSqlFullOuterJoin(stateBean)
        }
    }

    public func dealWithSqlCreateView(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 11 && matchKw(chars, idx, "create view ")) {
            stateBean.isInCreateView = true
        }
    }

    public func dealWithSqlCreateProcedure(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 16 && matchKw(chars, idx, "create procedure ")) {
            stateBean.isInCreateProcedure = true
        }
    }

    public func dealWithSqlCreateFunction(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 15 && matchKw(chars, idx, "create function ")) {
            stateBean.isInCreateFunction = true
        }
    }

    public func dealWithSqlShowColumns(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 12 && matchKw(chars, idx, "show columns ")) {
            stateBean.isInShowColumn = true
        }
    }

    public func dealWithSqlShowIndex(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 10 && matchKw(chars, idx, "show index ")) {
            stateBean.isInShowIndex = true
        }
    }

    public func dealWithSqlCreateTable(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 12 && matchKw(chars, idx, "create table ")) {
            stateBean.isInCreateTable = true
            stateBean.isHasCreateTableLeft = true
            stateBean.isHasCreateTableRight = true
        }
    }

    public func dealWithSqlAlterTable(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 11 && matchKw(chars, idx, "alter table ")) {
            stateBean.isInAlterTable = true
        }
    }

    public func dealWithSqlAddConstraint(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 14 && matchKw(chars, idx, "add constraint ")) {
            dealWithInSqlAddConstraint(stateBean)
        }
    }

    public func dealWithSqlOnSchedule(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 11 && matchKw(chars, idx, "on schedule ")) {
            dealWithInSqlOnSchedule(stateBean)
        }
    }

    public func dealWithSqlAlterColumn(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 12 && matchKw(chars, idx, "alter column ")) {
            dealWithInSqlAlterColumn(stateBean)
            stateBean.isInAlterColumn = true
        }
    }

    public func dealWithSqlAddColumn(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 10 && matchKw(chars, idx, "add column ")) {
            dealWithInSqlAddColumn(stateBean)
        }
    }

    public func dealWithSqlModifyColumn(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 13 && matchKw(chars, idx, "modify column ")) {
            dealWithInSqlModifyColumn(stateBean)
        }
    }

    public func dealWithSqlDropColumn(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 11 && matchKw(chars, idx, "drop column ")) {
            dealWithInSqlDropColumn(stateBean)
        }
    }

    public func dealWithSqlRestore(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7 && matchKw(chars, idx, "restore ")) {
            stateBean.isInRestore = true
        }
    }

    public func dealWithSqlFetchNext(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 10 && matchKw(chars, idx, "fetch next ")) {
            stateBean.isInFecthNext = true
        }
    }

    public func dealWithSqlGrant(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "grant ")) {
            stateBean.isInGrant = true
        }
    }

    public func dealWithSqlWaitFor(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7 && matchKw(chars, idx, "waitfor ")) {
            stateBean.isInWaitFor = true
        }
    }

    public func dealWithSqlUntil(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "until ")) {
            stateBean.isInUntil = true
        }
    }

    public func dealWithSqlExplain(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7 && matchKw(chars, idx, "explain ")) {
            stateBean.isInExplain = true
        }
    }

    public func dealWithSqlRevoke(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 6 && matchKw(chars, idx, "revoke ")) {
            stateBean.isInRevoke = true
        }
    }

    public func dealWithSqlSelect(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 6) {
            if (matchKw(chars, idx, "select ") && chars[idx] == r' ') {
                stateBean.isInSelect = true
                if(stateBean.isInGrant){
                    stateBean.isInGrant = false
                    return
                }
                if(stateBean.isInExplain){
                    return
                }
                if(stateBean.isInRevoke){
                    return
                }
                dealWithInSqlSelect(stateBean, 1)
            } else if (matchKw(chars, idx, "select*")) {
                stateBean.isInSelect = true
                if(stateBean.isInGrant){
                    stateBean.isInGrant = false
                    return
                }
                if(stateBean.isInExplain){
                    return
                }
                if(stateBean.isInRevoke){
                    return
                }
                dealWithInSqlSelect(stateBean, 2)
            }
        }
    }

    public func dealWithSqlSubSelect(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7 && matchKw(chars, idx, "(select ")) {
            if(!stateBean.isInSubSelect){
                stateBean.isInSubSelectCount++
            }
            stateBean.isInSubSelect = true
            if(stateBean.isInSet){
                return
            }
            dealWithInSqlSubSelect(stateBean)
        }
    }

    public func dealWithSqlDeleteFrom(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 10 && matchKw(chars, idx, "delete from")) {
            stateBean.isInDeleteFrom = true
        }
    }

    public func dealWithSqlOffSet(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 6 && matchKw(chars, idx, "offset ")) {
            stateBean.isInOffSet = true
            if(stateBean.isInOrderBy){
                dealWithInSqlOffSet(stateBean)
            }
        }
    }

    public func dealWithSqlEnum(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 4 && matchKw(chars, idx, "enum(")) {
            stateBean.isInEnum = true
        }
    }

    public func dealWithSqlIdentity(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 8 && matchKw(chars, idx, "identity(")) {
            stateBean.isInIdentity = true
        }
    }

    public func dealWithSqlFrom(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 3 && matchKw(chars, idx, "from")) {
            stateBean.isInSelect = false
            stateBean.isInFrom = true
            stateBean.isHasFrom = true

            if(stateBean.isInShowIndex){
                stateBean.isInShowIndex = false
                return
            }
            if(stateBean.isInShowColumn){
                stateBean.isInShowColumn = false
                return
            }
            if(stateBean.isInRevoke){
                stateBean.isInRevoke = false
                return
            }
            if(stateBean.isInExplain){
                stateBean.isInExplain = false
                return
            }
            if(stateBean.isInRestore){
                stateBean.isInRestore = false
                return
            }
            if(stateBean.isInFecthNext){
                stateBean.isInFecthNext = false
                return
            }
            dealWithInSqlFrom(stateBean)
        }
    }

    public func dealWithSqlSet(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 3 && matchKw(chars, idx, "set ")) {
            if(stateBean.isInAlterColumn){
                stateBean.isInAlterColumn = false
            }else if(stateBean.isInSet){
                stateBean.isInSet = false
            }else if(stateBean.isInCharacter){
                stateBean.isInCharacter = false
            }else{
                dealWithInSqlSet(stateBean)
            }
            stateBean.isInSet = true
        }
    }

    public func dealWithSqlWhere(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "where ")) {
            stateBean.isHasWhere = true
            stateBean.isInWhere = true
            dealWithInSqlWhere(stateBean)
        }
    }

    public func dealWithSqlAnd(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 3 && matchKw(chars, idx, "and ")) {
            if(stateBean.isInBetween){
                stateBean.isInBetween = false
            }else{
                stateBean.subSelectHasInAndOr = true
                dealWithInAnd(stateBean)
            }
        }
    }

    public func dealWithSqlOr(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 2 && matchKw(chars, idx, "or ")) {
            stateBean.subSelectHasInAndOr = true
            if(stateBean.isInWaitFor){
                stateBean.isInWaitFor = false
                return
            }
            if(stateBean.isInFor){
                return
            }
            dealWithInOr(stateBean)
        }
    }

    public func dealWithSqlGroupBy(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 8 && matchKw(chars, idx, "group by ")) {
            stateBean.isInGroupBy = true
            dealWithInGroupBy(stateBean)
        }
    }

    public func dealWithSqlHaving(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 6 && matchKw(chars, idx, "having ")) {
            if(stateBean.isInGroupBy){
                stateBean.isInGroupBy = false
            }
            dealWithInHaving(stateBean)
        }
    }

    public func dealWithSqlOrderBy(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 8 && matchKw(chars, idx, "order by ")) {
            if(stateBean.isInGroupBy){
                stateBean.isInGroupBy = false
            }
            stateBean.isInOrderBy = true
            if(!stateBean.isInOver){
                dealWithInOrderBy(stateBean)
            }
        }
    }

    public func dealWithSqlLimit(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 5 && matchKw(chars, idx, "limit ")) {
            if(stateBean.isInGroupBy){
                stateBean.isInGroupBy = false
            }
            if(stateBean.isInOrderBy){
                stateBean.isInOrderBy = false
            }
            dealWithInLimit(stateBean)
        }
    }

    public func dealWithSqlSmallBracket(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if(notNullChar[currentIndex] == r'('){
            if(stateBean.isInSubSelect){
                stateBean.isInSubSelectCount++
            }
            stateBean.isSqlSmallBracket ++
            if(stateBean.isInCreateTable && stateBean.isFirstCreateTableLeft){
                stateBean.isFirstCreateTableLeft = false
                dealWithSmallLeftBracket(stateBean)
                return true
            }
        }
        if(notNullChar[currentIndex] == r')'){
            if(stateBean.isInEnum){
                stateBean.isInEnum = false
            }
            if(stateBean.isInIdentity){
                stateBean.isInIdentity = false
            }
            if(stateBean.isInSubSelect){
                stateBean.isInSubSelectCount--
                if(stateBean.isInSubSelectCount == 0){
                    stateBean.isInSubSelect = false
                    stateBean.isJustTurnSubSelectFalse = true
                }
            }
            stateBean.isSqlSmallBracket --
            if(stateBean.isInCreateTable && stateBean.isFirstCreateTableRight && stateBean.isSqlSmallBracket == 0){
                stateBean.isFirstCreateTableRight = false
                dealWithSmallRightBracket(stateBean)
                return true
            }
        }
        return false
    }

    public func dealWithSqlBetween(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        if (idx >= 7 && matchKw(chars, idx, "between ")) {
            stateBean.isInBetween = true
        }
    }

    public func dealWithInSqlSelect(stateBean: StateBean,catagory:Int64): Unit {
        let offset = 7
        let lb = createLineBean(stateBean, offset)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInFor){
            stateBean.indentLevel++
        }
        if(stateBean.isInDo){
            stateBean.indentLevel++
        }
        if(stateBean.isInAsTwo){
            stateBean.indentLevel++
        }
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.perLineOutput.append("SELECT" + if(catagory == 1) { " " } else { "*" })
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex + 1 - offset
        stateBean.lastChar = if(catagory == 1) { r' ' } else { r'*' }
    }

    public func dealWithInSqlSubSelect(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 8, r' ')
    }

    public func dealWithInSqlFrom(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 4)
        if(!stateBean.isInBegin){
            if(lb.codeLine.startsWith("SELECT") && stateBean.isInSubSelectCount == 0 && !stateBean.isInFor){
                stateBean.indentLevel = 0
                stateBean.isInBetween = false
                stateBean.isInWhere  = false
                stateBean.isHasWhere  = false
                stateBean.isInValues  = false
                stateBean.isSqlSmallBracket  = 0
                stateBean.isInSet  = false
                stateBean.isInSelect  = false
                stateBean.isInDeleteFrom = false
                stateBean.isInMultiJoin = false
                stateBean.isInJoin  = false
                stateBean.isInGroupBy  = false
                stateBean.isInOrderBy = false
                stateBean.isInCreateTable = false
                stateBean.isHasCreateTableLeft = false
                stateBean.isHasCreateTableRight = false
                stateBean.isFirstCreateTableLeft = true
                stateBean.isFirstCreateTableRight = true
                stateBean.isInAlterTable = false
                stateBean.isInSubSelect = false
                stateBean.isInSubSelectCount = 0
                stateBean.isJustTurnSubSelectFalse = false
                stateBean.subSelectHasInAndOr=false
            }
        }
        if(stateBean.isInSubSelect){
            stateBean.indentLevel ++
            if(stateBean.isHasWhere){
                if(!stateBean.subSelectHasInAndOr){
                    stateBean.indentLevel ++
                }
            }
         }
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                stateBean.indentLevel--
            }
        }
        if(stateBean.isInEndAs){
            stateBean.indentLevel--
        }
        finishLine(lb, stateBean, 4, r'm', advance:false)
        stateBean.perLineOutput.append("FROM")
    }

    public func dealWithInSqlSet(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 4)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInWhile && stateBean.isInDo){
            stateBean.indentLevel++
        }
        if(stateBean.isInContinue){
            stateBean.indentLevel--
        }
        finishLine(lb, stateBean, 4, r' ')
    }

    public func dealWithInSqlOffSet(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 7, r' ')
    }

    public func dealWithInSqlWhere(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 6)
        if(stateBean.isInSet){
            stateBean.isInSet = false
        }
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isHasFrom && stateBean.isInJoin){
            if(stateBean.indentLevel > 0){
                stateBean.indentLevel--
            }
            stateBean.isHasFrom = false
            stateBean.isInJoin = false
        }else{
            if(stateBean.isInSubSelectCount == 0){
                stateBean.indentLevel = 0
            }
        }
        if(stateBean.isInBegin){
            stateBean.indentLevel++
        }
        finishLine(lb, stateBean, 6, r' ')
    }

    public func dealWithInOrderBy(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 9)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInSubSelectCount == 0){
            stateBean.indentLevel = 0
        }
        if(stateBean.isHasWhere){
            stateBean.indentLevel--
            stateBean.subSelectHasInAndOr = false
            stateBean.isHasWhere = false
        }
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                stateBean.indentLevel--
            }
        }
        finishLine(lb, stateBean, 9, r' ')
    }

    public func dealWithInGroupBy(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 9)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInSubSelectCount == 0){
            stateBean.indentLevel = 0
        }
        if(stateBean.isHasWhere){
            stateBean.indentLevel--
            stateBean.subSelectHasInAndOr = false
            stateBean.isHasWhere = false
        }
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                stateBean.indentLevel--
            }
        }
        finishLine(lb, stateBean, 9, r' ')
    }

    public func dealWithInHaving(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 7)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInSubSelectCount == 0){
            stateBean.indentLevel = 0
        }
        if(stateBean.isHasWhere){
            stateBean.indentLevel--
            stateBean.subSelectHasInAndOr = false
            stateBean.isHasWhere = false
        }
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                stateBean.indentLevel--
            }
        }
        finishLine(lb, stateBean, 7, r' ')
    }

    public func dealWithInLimit(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 6)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInSubSelectCount == 0){
            stateBean.indentLevel = 0
        }
        if(stateBean.isHasWhere){
            stateBean.indentLevel--
            stateBean.subSelectHasInAndOr = false
            stateBean.isHasWhere = false
        }
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                stateBean.indentLevel--
            }
        }
        finishLine(lb, stateBean, 6, r' ')
    }

    public func dealWithInAnd(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 4)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInWhere){
            stateBean.indentLevel++
            stateBean.isInWhere = false
        }
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                stateBean.indentLevel--
            }
        }
        let rawContent = lb.codeLine.trimAscii().replace(" ","")
        if(rawContent.startsWith("AND(") || rawContent.startsWith("OR(")){
             stateBean.indentLevel++
        }
        if((rawContent.startsWith("AND") && rawContent.endsWith(")")) || (rawContent.startsWith("OR") && rawContent.endsWith(")"))){
             stateBean.indentLevel--
        }
        finishLine(lb, stateBean, 4, r' ')
    }

    public func dealWithInOr(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 3)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInWhere){
            stateBean.indentLevel++
            stateBean.isInWhere = false
        }
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                stateBean.indentLevel--
            }
        }
        let rawContent = lb.codeLine.trimAscii().replace(" ","")
        if(rawContent.startsWith("AND(") || rawContent.startsWith("OR(")){
             stateBean.indentLevel++
        }
        if((rawContent.startsWith("AND") && rawContent.endsWith(")")) || (rawContent.startsWith("OR") && rawContent.endsWith(")"))){
             stateBean.indentLevel--
        }
        finishLine(lb, stateBean, 3, r' ')
    }

    public func dealWithInSqlRenameTable(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        lb.indentLevel = stateBean.indentLevel
        stateBean.indentLevel++
        finishLine(lb, stateBean, 0, r' ')
    }

    public func dealWithInSqlValues(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 6, r's')
    }

    public func dealWithInSqlWith(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 5, r' ')
    }

    public func dealWithInSqlBegin(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 6)
        lb.indentLevel = stateBean.indentLevel
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        let lineBean2: LineBean = LineBean()
        lineBean2.codeLine = "BEGIN"
        lineBean2.indentLevel = stateBean.indentLevel
        let flag:FlagBean = FlagBean("BEGIN",stateBean.indentLevel)
        arrayListFlagBegin.add(flag)
        stateBean.indentLevel++
        setCommonFields(lineBean2, stateBean)
        stateBean.linesList.add(lineBean2)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r' '
    }

    public func dealWithInSqlCase(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 5)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInSelect){
            stateBean.indentLevel++
        }
        let flag:FlagBean = FlagBean("CASE",stateBean.indentLevel)
        arrayListFlagCase.add(flag)
        finishLine(lb, stateBean, 5, r' ')
    }

    public func dealWithInSqlIf(stateBean: StateBean): Unit {
        let flag:FlagBean = FlagBean("IF",stateBean.indentLevel)
        arrayListFlagIF.add(flag)
    }

    public func dealWithInSqlWhen(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 5)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInCase){
            stateBean.isInCase = false
            stateBean.indentLevel++
        }
        finishLine(lb, stateBean, 5, r' ')
    }

    public func dealWithInSqlThen(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        lb.indentLevel = stateBean.indentLevel
        stateBean.indentLevel++
        finishLine(lb, stateBean, 0, r' ', advance: false)
    }

    public func dealWithInSqlElse(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 6)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInIf){
            stateBean.isInIf = false
            stateBean.indentLevel--
        }
        finishLine(lb, stateBean, 6, r' ', advance:false)
    }

    public func dealWithInSqlBreak(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 6)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInIfFirst || stateBean.isInElseFirst){
            stateBean.isInIfFirst = false
            stateBean.isInElseFirst = false
            stateBean.indentLevel++
        }
        finishLine(lb, stateBean, 6, r' ')
    }

    public func dealWithInSqlContinue(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 9)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInIfFirst || stateBean.isInElseFirst){
            stateBean.isInIfFirst = false
            stateBean.isInElseFirst = false
            stateBean.indentLevel++
        }
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex + 1 - 9
        stateBean.lastChar = r'e'
    }

    public func dealWithInSqlEnd(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 4)
        lb.indentLevel = stateBean.indentLevel
        if(arrayListFlagBegin.size>0){
            let beginflagBean = arrayListFlagBegin.get(arrayListFlagBegin.size - 1).getOrThrow()
            stateBean.indentLevel = beginflagBean.flagIndent
            arrayListFlagBegin.remove(at: arrayListFlagBegin.size - 1)
        }
        if(arrayListFlagCase.size>0){
            let caseflagBean = arrayListFlagCase.get(arrayListFlagCase.size - 1).getOrThrow()
            stateBean.indentLevel = caseflagBean.flagIndent
            arrayListFlagCase.remove(at: arrayListFlagCase.size - 1)
        }
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex + 1 - 4
        stateBean.lastChar = r' '
    }

    public func dealWithInSqlEndIF(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 8)
        lb.indentLevel = stateBean.indentLevel
        if(arrayListFlagIF.size>0){
            let ifflagBean = arrayListFlagIF.get(arrayListFlagIF.size - 1).getOrThrow()
            stateBean.indentLevel = ifflagBean.flagIndent
            arrayListFlagIF.remove(at: arrayListFlagIF.size - 1)
        }
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex + 1 - 8
        stateBean.lastChar = r' '
    }

    public func dealWithInSqlEndAs(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 8)
        lb.indentLevel = stateBean.indentLevel
        if(arrayListFlagCase.size>0){
            let caseflagBean = arrayListFlagCase.get(arrayListFlagCase.size - 1).getOrThrow()
            stateBean.indentLevel = caseflagBean.flagIndent
            arrayListFlagCase.remove(at: arrayListFlagCase.size - 1)
        }
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex + 1 - 8
        stateBean.lastChar = r' '
    }

    public func dealWithInSqlPivot(stateBean: StateBean,types:Int32): Unit {
        let lb = createLineBean(stateBean, 6)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.indentLevel > 0){
            stateBean.indentLevel --
        }
        finishLine(lb, stateBean, 6, if(types == 0) { r' ' } else { r'(' })
    }

    public func dealWithInSqlUnpivot(stateBean: StateBean,types:Int32): Unit {
        let lb = createLineBean(stateBean, 8)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.indentLevel > 0){
            stateBean.indentLevel --
        }
        finishLine(lb, stateBean, 8, if(types == 0) { r' ' } else { r'(' })
    }

    public func dealWithInSqlAddColumn(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 11)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInAlterTable){
            stateBean.indentLevel++
            stateBean.isInAlterTable = false
        }
        finishLine(lb, stateBean, 11, r' ')
    }

    public func dealWithInSqlOnSchedule(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 12, r' ')
    }

    public func dealWithInSqlAddConstraint(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 15)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInAlterTable){
            stateBean.indentLevel++
            stateBean.isInAlterTable = false
        }
        finishLine(lb, stateBean, 15, r' ')
    }

    public func dealWithInSqlAlterColumn(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 13)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInAlterTable){
            stateBean.indentLevel++
            stateBean.isInAlterTable = false
        }
        finishLine(lb, stateBean, 13, r' ')
    }

    public func dealWithInSqlModifyColumn(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 14)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInAlterTable){
            stateBean.indentLevel++
            stateBean.isInAlterTable = false
        }
        finishLine(lb, stateBean, 14, r' ')
    }

    public func dealWithInSqlDropColumn(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 12)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInAlterTable){
            stateBean.indentLevel++
            stateBean.isInAlterTable = false
        }
        finishLine(lb, stateBean, 12, r' ')
    }

    public func dealWithSqlInUnion(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 6, r' ')
    }

    public func dealWithSqlInIntersect(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 10, r' ')
    }

    public func dealWithSqlInExcept(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 7, r' ')
    }

    public func dealWithSqlInUnionAll(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 9, r'l')
    }

    public func dealWithInSqlAs(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 4, r' ')
    }

    public func dealWithInSqlAsTwo(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 6, r' ')
    }

    public func dealWithInSqlTwoLanguage(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 12)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.indentLevel>0){
            stateBean.indentLevel --
        }
        finishLine(lb, stateBean, 12, r' ')
    }

    public func dealWithInSqlLanguage(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 10)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.indentLevel>0){
            stateBean.indentLevel --
        }
        finishLine(lb, stateBean, 10, r' ')
    }

    public func dealWithInSqlDo(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 4, r' ')
    }

    public func dealWithInSqlLoop(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        lb.indentLevel = stateBean.indentLevel
        stateBean.indentLevel++
        finishLine(lb, stateBean, 0, r' ')
    }

    public func dealWithInSqlBefore(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 7, r' ')
    }

    public func dealWithInSqlForEach(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 9, r' ')
    }

    public func dealWithInSqlExecuteFunction(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 17, r' ')
    }

    public func dealWithInSqlReturns(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 8, r' ')
    }

    public func dealWithInSqlInsteadOf(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 11, r' ')
    }

    public func dealWithInSqlReturn(stateBean: StateBean): Unit {
        makeSimpleLine(stateBean, 7, r' ')
    }

    public func dealWithInSqlRepeat(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        lb.indentLevel = stateBean.indentLevel
        stateBean.indentLevel++
        finishLine(lb, stateBean, 0, r' ')
    }

    public func dealWithInSqlEndRepeat(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 10)
        if(stateBean.isInUntil){
            stateBean.indentLevel++
        }
        lb.indentLevel = stateBean.indentLevel
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.perLineOutput.append("END REPEAT")
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex + 1 - 10
        stateBean.lastChar = r't'
    }

    public func dealWithInSqlJoin(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 5)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        finishLine(lb, stateBean, 5, r' ')
    }

    public func dealWithInSqlCrossJoin(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 11)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        finishLine(lb, stateBean, 11, r' ')
    }

    public func dealWithInSqlInnerJoin(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 11)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        finishLine(lb, stateBean, 11, r' ')
    }

    public func dealWithInSqlLeftJoin(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 10)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        finishLine(lb, stateBean, 10, r' ')
    }

    public func dealWithInSqlRightJoin(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 11)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        finishLine(lb, stateBean, 11, r' ')
    }

    public func dealWithInSqlFullOuterJoin(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 16)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        finishLine(lb, stateBean, 16, r' ')
    }

    public func dealWithSqlComma(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isInValues){
            stateBean.indentLevel++
            stateBean.isInValues = false
        }
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r','
        stateBean.currentIndex++
    }

    public func dealWithSmallLeftBracket(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isHasCreateTableLeft){
            stateBean.indentLevel++
            stateBean.isHasCreateTableLeft = false
        }
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'('
        stateBean.currentIndex++
    }

    public func dealWithSmallRightBracket(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        lb.indentLevel = stateBean.indentLevel
        if(stateBean.isHasCreateTableRight){
            stateBean.indentLevel--
            stateBean.isHasCreateTableRight = false
        }
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r')'
        stateBean.currentIndex++
    }

    func formatCode(rawCode: String, cfg: FormatConfig): String {
        let runCode = rawCode.replace("\r\n","\n")
        var realRawCode = runCode.trimAscii()
        if(!realRawCode.endsWith(";")){
            realRawCode = realRawCode+";"
        }
        let stateBean: StateBean = StateBean()
        stateBean.linesList = ArrayList<LineBean>()
        stateBean.codeChars = realRawCode.toRuneArray()
        if (let Some(i) <- stateBean.codeChars) {
            let len = i.size
            if (len == 0) {
                return ""
            }
            while (stateBean.currentIndex < len) {
                let currChar = i[stateBean.currentIndex]
                stateBean.perLineOutput.append(currChar)
                if (currChar == r'-' && stateBean.lastChar == r'-' && !stateBean.isInString) {
                    var str = stateBean.perLineOutput.toString().removeSuffix("--")
                    if (str.trimAscii().size > 0) {
                        dealWithSingleLineComment(stateBean, str)
                    } else {
                        dealWithSingleLineComment(stateBean, "")
                    }
                    continue
                }
                if (currChar == r'*' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    var str = stateBean.perLineOutput.toString().removeSuffix("/*")
                    if (str.trimAscii().size > 0) {
                        dealWithMultiLineComment(stateBean, str)
                    } else {
                        dealWithMultiLineComment(stateBean, "")
                    }
                    continue
                }
                dealWithString(stateBean)

                if (!stateBean.isInString) {
                    for(i in 0..KeyWorldList.size){
                        dealWithSqlKeyWord(stateBean,KeyWorldList[i])
                    }
                 }

                if (!stateBean.isInString) {
                    dealWithFor(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlShowColumns(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlShowIndex(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlCreateView(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlCreateProcedure(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlCreateFunction(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlCreateTable(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlOnSchedule(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlAlterTable(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlAddConstraint(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlAlterColumn(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlAddColumn(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlModifyColumn(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlDropColumn(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlSubSelect(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlRestore(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlFetchNext(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlWaitFor(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlGrant(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlRevoke(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlExplain(stateBean)
                }

                if (!stateBean.isInString) {
                    if(!stateBean.isInSubSelect){
                        dealWithSqlSelect(stateBean)
                    }
                }

                if (!stateBean.isInString) {
                    dealWithSqlDeleteFrom(stateBean)
                }

                if (!stateBean.isInString) {
                    if(stateBean.isInDeleteFrom){
                        stateBean.isInDeleteFrom = false
                    }else{
                        dealWithSqlFrom(stateBean)
                    }
                }

                if (!stateBean.isInString) {
                    dealWithSqlRenameTable(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlValues(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlUnpivot(stateBean)
                }

                if (!stateBean.isInString) {
                    if(stateBean.isInUnpivot){
                        stateBean.isInUnpivot = false
                    }else{
                        dealWithSqlPivot(stateBean)
                    }
                }

                if (!stateBean.isInString) {
                    dealWithSqlWith(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlCase(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlBegin(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlIf(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlWhen(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlThen(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlElse(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlBreak(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlContinue(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlEndIF(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlEndAs(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlEnd(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlOffSet(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlEnum(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlIdentity(stateBean)
                }

                if (!stateBean.isInString) {
                    if(stateBean.isInOffSet){
                        stateBean.isInOffSet = false
                    }else{
                        dealWithSqlSet(stateBean)
                    }
                }

                if (!stateBean.isInString) {
                    dealWithSqlWhere(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlAnd(stateBean)
                }

                if(!stateBean.isInString){
                    dealWithSqlDeclare(stateBean)
                }

                if(!stateBean.isInString){
                    dealWithSqlCursor(stateBean)
                }

                if (!stateBean.isInString) {
                    if(stateBean.isInCursor){
                        stateBean.isInCursor = false
                    }else{
                        dealWithSqlOr(stateBean)
                    }
                }

                if (!stateBean.isInString) {
                    dealWithSqlBetween(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlGroupBy(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlHaving(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlOrderBy(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlLimit(stateBean)
                }

                if (!stateBean.isInString) {
                   let res = dealWithSqlSmallBracket(stateBean)
                   if(res){
                     continue
                   }
                }

                if (!stateBean.isInString) {
                    dealWithSqlIntersect(stateBean)
                }

                 if (!stateBean.isInString) {
                    dealWithSqlExcept(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlUnionAll(stateBean)
                }

                if (!stateBean.isInString) {
                      if(stateBean.isInUnionAll){
                        stateBean.isInUnionAll = false
                      }else{
                        dealWithSqlUnion(stateBean)
                      }
                }

                if (!stateBean.isInString) {
                    dealWithSqlInnerJoin(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlCrossJoin(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlLeftJoin(stateBean)
                }

                 if (!stateBean.isInString) {
                    dealWithSqlRightJoin(stateBean)
                }

                 if (!stateBean.isInString) {
                    dealWithSqlFullOuterJoin(stateBean)
                }

                if(!stateBean.isInString){
                    dealWithSqlCharacter(stateBean)
                }

                if(!stateBean.isInString){
                    dealWithSqlOver(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlLoop(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlUntil(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlBefore(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlReturns(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlInsteadOf(stateBean)
                }

                if (!stateBean.isInString) {
                    if(stateBean.isInReturns){
                        stateBean.isInReturns = false
                    }else{
                        dealWithSqlReturn(stateBean)
                    }
                }

                if (!stateBean.isInString) {
                    dealWithSqlExecuteFunction(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlForEach(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlEndRepeat(stateBean)
                }

                if (!stateBean.isInString) {
                    if(!stateBean.isInEndRepeat){
                         dealWithSqlRepeat(stateBean)
                    }
                }

                if (!stateBean.isInString) {
                    dealWithSqlWhile(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlDo(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlAsTwo(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlTwoLanguage(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlLanguage(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlAs(stateBean)
                }

                if (!stateBean.isInString) {
                    if(stateBean.isInMultiJoin){
                        stateBean.isInMultiJoin = false
                    }else{
                        dealWithSqlJoin(stateBean)
                    }
                }

                if (currChar == r',' && ((!stateBean.isInGroupBy && !stateBean.isInOrderBy  &&!stateBean.isInSet && !stateBean.isInSelect && stateBean.isSqlSmallBracket == 0) || stateBean.isInCreateTable)   && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInSinglelineComment && !stateBean.isInMultilineComment) {
                    if(!stateBean.isInEnum && !stateBean.isInIdentity && !stateBean.isInGrant){
                        dealWithSqlComma(stateBean)
                        continue
                    }
                }

                if (currChar == r';' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInSinglelineComment && !stateBean.isInMultilineComment) {
                    dealWithSemicolon(stateBean)
                    if(!stateBean.isInBegin){
                        stateBean.indentLevel = 0
                        stateBean.isInBetween = false
                        stateBean.isInWhere  = false
                        stateBean.isHasWhere  = false
                        stateBean.isInValues  = false
                        stateBean.isSqlSmallBracket  = 0
                        stateBean.isInSet  = false
                        stateBean.isInSelect  = false
                        stateBean.isInDeleteFrom = false
                        stateBean.isInMultiJoin = false
                        stateBean.isInFrom  = false
                        stateBean.isHasFrom  = false
                        stateBean.isInJoin  = false
                        stateBean.isInGroupBy  = false
                        stateBean.isInOrderBy = false
                        stateBean.isInCreateTable = false
                        stateBean.isHasCreateTableLeft = false
                        stateBean.isHasCreateTableRight = false
                        stateBean.isFirstCreateTableLeft = true
                        stateBean.isFirstCreateTableRight = true
                        stateBean.isInAlterTable = false
                        stateBean.isInSubSelect = false
                        stateBean.isInSubSelectCount = 0
                        stateBean.isJustTurnSubSelectFalse = false
                        stateBean.subSelectHasInAndOr=false
                    }
                    continue
                }
                if (currChar == r'\n' && !stateBean.isInString) {
                    dealWithNewLine(stateBean)
                    stateBean.isLineStart = true
                } else {
                    if (stateBean.isLineStart && (currChar == r' ' || currChar == r'\t')) {
                        stateBean.isLineStart = true
                    } else {
                        stateBean.isLineStart = false
                    }
                }
                stateBean.lastChar = currChar
                stateBean.currentIndex++
            }
            dealWithNewLine(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.singlelineCommentisAfterChangeLine) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            for (j in 0..lineBean.singleLineWhiteSpace) {
                                stringbuilder.append(" ")
                            }
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInMultilineComment && lineBean.isFirstMultiCommentLine) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.multilineCommentisAfterChangeLine) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(" ")
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }

            removeOnlyChangeLine(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ","")
                if ((codeStr.startsWith("WHERE") || codeStr.startsWith("AND") ||codeStr.startsWith("OR")) && codeStr.contains("\n")  && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    lineBean.codeLine = lineBean.codeLine.replace("\n","")
                }
            }

            for (item in stateBean.linesList) {
                item.codeLine = item.codeLine.trimAscii()
                if(item.codeLine.endsWith(";")){
                    item.codeLine = item.codeLine+"\n"
                }
            }

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if ((lineBean.codeLine.trimAscii().replace(" ","") == "ENDWHILE;" ||
                lineBean.codeLine.trimAscii().replace(" ","") == "ENDLOOP;" ||
                lineBean.codeLine.trimAscii().replace(" ","") == "END;" ||
                lineBean.codeLine.trimAscii().replace(" ","") == "END$$;" ||
                lineBean.codeLine.trimAscii().replace(" ","") == "ENDIF;" ||
                lineBean.codeLine.trimAscii().replace(" ","") == "$$;" ||
                lineBean.codeLine.trimAscii().startsWith("PRINT(")  ||
                lineBean.codeLine.trimAscii().startsWith("UNTIL")) && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if(lastLineBean.codeLine.endsWith("\n")){
                            lastLineBean.codeLine = lastLineBean.codeLine.removeSuffix("\n")
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii().replace(" ","") == "BEGIN" && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if(nextLineBean.codeLine.trimAscii().replace(" ","") == "TRANSACTION;"){
                            lineBean.codeLine = "BEGIN TRANSACTION;"
                            nextLineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii().replace(" ","") == "END$$;" && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    lineBean.codeLine = "END;\n$$;"
                }
            }

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii().replace(" ","") == "CONTINUE;" && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    lineBean.codeLine = "CONTINUE;"
                }
            }

            let usefulList: ArrayList<LineBean> = stateBean.linesList

            for (index in 0..usefulList.size) {
                let item: LineBean = usefulList[index]
                addIndent(stateBean.output, item.indentLevel, cfg)
                stateBean.output.append(item.codeLine)
                if (index != usefulList.size - 1) {
                    stateBean.output.append("\n")
                }
            }
            return stateBean.output.toString().trimAscii()
        } else {
            return ""
        }
    }
}
