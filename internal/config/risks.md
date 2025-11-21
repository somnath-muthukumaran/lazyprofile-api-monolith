🚨 Risk 1: Security Log Leak (High Severity)
The Risk: If a developer accidentally logs the configuration struct using fmt.Println(config.GetConfig()) or a logger, your database password will be written to the logs in plain text. This is a common security audit failure.

The Fix: Implement the Stringer interface to redact sensitive fields when printed.

🚨 Risk 2: Concurrency / Race Condition (Medium Severity)
The Risk: LoadConfig writes to the global appConfig variable without a lock. If your application attempts to run parallel tests or if LoadConfig is accidentally called from two goroutines at startup, you will have a Race Condition.

The Fix: Use sync.Once to ensure configuration is loaded exactly once, safely.

🚨 Risk 3: Testability (Medium Severity)
The Risk: Because appConfig is a global singleton, running parallel unit tests is difficult. If Test A sets the DB host to "localhost" and Test B sets it to "test-db", they will conflict because they share the same global variable.

The Fix: While Dependency Injection is the ultimate fix (passing config as an argument), for this pattern, adding a Reset() method (only for tests) or accepting the "limitation" that tests must run sequentially is standard.