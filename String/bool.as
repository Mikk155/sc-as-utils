namespace String
{
    /**
     * Parses common boolean text representations.
     *
     * @param input Text interpreted as true when its numeric value is nonzero or
     *              its case-insensitive value is "true"; otherwise false.
     */
    bool to_bool( const string&in input )
    {
        return ( atoi( input ) != 0 || input.ToLowercase() == "true" );
    }

    /**
     * Converts a boolean value to text.
     *
     * @param input Boolean value to format.
     * @param make_digit If true, returns "1" or "0"; otherwise returns "True" or "False".
     */
    string to_string( bool input, bool make_digit = false )
    {
        if( make_digit )
        {
            return ( input ? "1" : "0" );
        }
        return ( input ? "True" : "False" );
    }
}
