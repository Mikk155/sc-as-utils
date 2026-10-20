namespace Server
{
    /**
     * Checks whether a server plugin with the given name is loaded.
     *
     * @param plugin_name Plugin name to search for.
     * @param case_sensitive Whether the name must match letter case exactly. Defaults to false.
     */
    bool IsPluginInstalled( const string&in plugin_name, bool case_sensitive = false )
    {
        array<string>@ pluginList = g_PluginManager.GetPluginList();

        if( case_sensitive )
        {
            return ( pluginList.find( plugin_name ) >= 0 );
        }

        string plugin_name_lowercase =  plugin_name.ToLowercase();

        for( uint ui = 0; ui < pluginList.length(); ui++ )
        {
            if( pluginList[ui].ToLowercase() == plugin_name_lowercase )
            {
                return true;
            }
        }
        return false;
    }
}
