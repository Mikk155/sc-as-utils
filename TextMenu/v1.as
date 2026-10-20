namespace TextMenu
{
    namespace v1
    {
        abstract class ASMenuTextHolder
        {
            MenuText m_Content();

            // Get string content.
            const string& get_Content()
            {
                return this.m_Content.String;
            }

            // Get a handler this class content string builder.
            MenuText@ get_Text()
            {
                return @this.m_Content;
            }
        }

        // const string[][] MenuColors = {
        const dictionary MenuColors = {
            { "white", "w" },
            { "gray", "d" },
            { "yellow", "y" },
            { "red", "r" },
            { "magenta", "m" },
            { "green", "g" },
            { "orange", "o" },
            { "cyan", "c" }
        };

        // Represents a CTextMenu option or title for ease of color setting using builder-patterns
        final class MenuText
        {
            MenuText() {}

            string m_Content;

            const string& get_String()
            {
                return this.m_Content;
            }

            /**
             * Appends text after replacing supported color tags with menu color codes.
             *
             * @param text Text to append. Tags such as "<red>" and "<r>" are converted
             *             in place to the corresponding CTextMenu color code.
             */
            MenuText@ Write( string&in text )
            {
                const array<string>@ keys = MenuColors.getKeys();
                uint length = keys.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    string colorName = keys[ui];
                    string color = string( MenuColors[ colorName ] );
                    string colorMatch = "<" + colorName + ">";

                    if( text.Find( colorMatch ) != String::INVALID_INDEX )
                    {
                        text.Replace( colorMatch, "\\" + color );
                    }

                    colorMatch = "<" + color + ">";

                    if( text.Find( colorMatch ) != String::INVALID_INDEX )
                    {
                        text.Replace( colorMatch, "\\" + color );
                    }
                }

                this.m_Content.opAddAssign( text );
                return this;
            }

            /**
             * Appends a raw CTextMenu color control code.
             *
             * @param color CTextMenu color control code to append, introduced by a
             *              backslash and followed by the color's letter.
             */
            MenuText@ Color( const string&in color )
            {
                this.m_Content.opAddAssign( color );
                return this;
            }

            MenuText@ ColorWhite()
            {
                return this.Color( "\\w" );
            }

            MenuText@ ResetColor()
            {
                return this.ColorWhite();
            }

            MenuText@ Clear()
            {
                this.m_Content = String::EMPTY_STRING;
                return this;
            }

            MenuText@ ColorGray()
            {
                return this.Color( "\\d" );
            }

            MenuText@ ColorYellow()
            {
                return this.Color( "\\y" );
            }

            MenuText@ ColorRed()
            {
                return this.Color( "\\r" );
            }

            MenuText@ ColorMagenta()
            {
                return this.Color( "\\m" );
            }

            MenuText@ ColorGreen()
            {
                return this.Color( "\\g" );
            }

            MenuText@ ColorOrange()
            {
                return this.Color( "\\o" );
            }

            MenuText@ ColorCyan()
            {
                return this.Color( "\\c" );
            }
        }

        /**
         * Callback invoked when a player selects a menu option.
         *
         * @param player Player who selected the option.
         * @param option Option selected by the player.
         */
        funcdef void MenuOptionSelect( CBasePlayer@ player, MenuOption@ option );

        class MenuOption : ASMenuTextHolder
        {
            dictionary@ m_Data;

            /**
             * Associates custom data with this option.
             *
             * @param data Dictionary to associate with the option; it may be null.
             */
            MenuOption@ SetData( dictionary@ data )
            {
                @this.m_Data = data;
                return this;
            }

            dictionary get_DataCopy()
            {
                if( this.m_Data !is null )
                    return this.m_Data;
                return {};
            }

            dictionary@ get_Data()
            {
                return @this.m_Data;
            }

            // Any constructor
            MenuOption() {}

            Menu@ m_Owner;

            // Get menu owning this option.
            Menu@ GetMenu()
            {
                return this.m_Owner;
            }

            uint m_Id;

            uint get_Id()
            {
                return this.m_Id;
            }

            MenuOptionSelect@ m_Callback = null;

            /**
             * Sets the function invoked when this option is selected.
             *
             * @param callback Selection callback, or null to clear the callback.
             */
            MenuOption@ SetCallback( MenuOptionSelect@ callback )
            {
                @this.m_Callback = callback;
                return this;
            }

            MenuOptionSelect@ GetCallback()
            {
                return this.m_Callback;
            }

            /**
             * Creates an option owned by the given menu.
             *
             * @param owner Menu that owns this option and determines its index.
             */
            MenuOption( Menu@ owner )
            {
                @this.m_Owner = owner;
                this.m_Id = owner.Length();
            }
        }

        class Menu : ASMenuTextHolder
        {
            array<CTextMenu@> m_Menus;

            array<MenuOption@> m_Options;

            array<MenuOption@>@ get_Options()
            {
                return @this.m_Options;
            }

            Menu()
            {
                this.m_Menus.resize(g_Engine.maxClients);
            }

            ~Menu()
            {
                uint length = this.m_Menus.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    CTextMenu@ menu = this.m_Menus[ui];

                    if( menu !is null )
                    {
                        if( menu.IsRegistered() )
                        {
                            menu.Unregister();
                        }
                        @this.m_Menus[ ui ] = null;
                    }
                }
            }

            uint Length()
            {
                return this.m_Options.length();
            }

            // Get the number of pages.
            uint get_Pages()
            {
                return int( ( this.m_Options.length() + 6 ) / 7 );
            }

            // Add a menu option.
            MenuOption@ AddOption()
            {
                MenuOption@ option = MenuOption( this );
                this.m_Options.insertLast( option );
                return option;
            }

            // Add a set count of menu options.
            uint AddOptions( uint options )
            {
                uint index = this.Length();

                for( uint ui = 0; ui < options; ui++ )
                {
                    this.AddOption();
                }

                return index;
            }

            /**
             * Dispatches the engine menu selection to the callback on its associated option.
             *
             * @param menu Engine menu that reported the selection.
             * @param player Player who selected an item.
             * @param slot Selected menu slot as reported by CTextMenu.
             * @param item Engine menu item containing the option's user data; null is ignored.
             */
            void InternalCallback( CTextMenu@ menu, CBasePlayer@ player, int slot, const CTextMenuItem@ item )
            {
                if( item !is null )
                {
                    MenuOption@ option;

                    if( item.m_pUserData !is null )
                    {
                        if( item.m_pUserData.retrieve( @option ) )
                        {
                            MenuOptionSelect@ callback = option.GetCallback();

                            if( callback !is null )
                            {
                                callback( player, option );
                            }
                        }
                    }
                }
            }

            /**
             * Opens this menu for one player on the requested page.
             *
             * @param player Player who will see the menu. If null, no menu is opened.
             * @param displayTime Number of seconds the menu remains open.
             * @param page Zero-based page index to display.
             */
            void Open( CBasePlayer@ player, uint displayTime = 10, uint page = 0 )
            {
                if( player is null )
                    return;

                uint index = player.entindex() - 1;

                CTextMenu@ menu = this.m_Menus[ index ];

                if( menu !is null )
                {
                    if( menu.IsRegistered() )
                    {
                        menu.Unregister();
                    }
                }

                @menu = CTextMenu( @TextMenuPlayerSlotCallback( this.InternalCallback ) );

                menu.SetTitle( this.Text.String );

                uint length = this.m_Options.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    MenuOption@ option = this.m_Options[ui];
                    menu.AddItem( option.Text.String, any(option) );
                }

                menu.Register();

                menu.Open( displayTime, page, player );

                @this.m_Menus[ index ] = menu;
            }

            /**
             * Opens this menu for every connected player on the requested page.
             *
             * @param displayTime Number of seconds the menu remains open.
             * @param page Zero-based page index to display.
             */
            void Open( uint displayTime = 10, uint page = 0 )
            {
                for( int i = 1; i <= g_Engine.maxClients; i++ )
                {
                    this.Open( g_PlayerFuncs.FindPlayerByIndex(i), displayTime, page );
                }
            }
        }
    }
}
