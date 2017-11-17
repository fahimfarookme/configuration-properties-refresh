# configuration-properties-refresh
PoC to verify whether @ConfigurationProperties are in RefreshScope

This PoC confirms that hitting the /refresh endpoint updates the `@ConfigurationProperties` beans even if they are not in @RefreshScope. During /refresh i.e. EnvironmentChangeEvent, `@ConfigurationProperties` beans are reinitialized by `ConfigurationPropertiesRebinder`. This means we can consider that `@ConfigurationProperties` beans are in refresh scope by default. 

