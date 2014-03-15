// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: Save_Army.cs
// ***************************************************************************************
// * 
// * This program is free software; you can redistribute it and/or modify
// * it under the terms of the GNU General Public License as published by
// * the Free Software Foundation; either version 3 of the License, or
// * (at your option) any later version.
// * 
// * This program is distributed in the hope that it will be useful,
// * but WITHOUT ANY WARRANTY; without even the implied warranty of
// * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// * GNU General Public License for more details.
// *
// * You should have received a copy of the GNU General Public License
// * along with this program; if not, write to the Free Software Foundation,
// * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
// ***************************************************************************************


using System;

public class Save_Army
{
    public static string GetArmiesText(int numberOfArmies)
    {
        string t = "    Armies = " + Environment.NewLine;
        t = t + "    {" + Environment.NewLine;
        for (int i = 1; i <= numberOfArmies; i++)
        {
            t = t + GetArmyText("ARMY_" + i);
        }
        t = t + GetArmyText("ARMY_20");
        t = t + "    }," + Environment.NewLine;
        return t;
    }
    private static string GetArmyText(string armyName)
    {
        string temp = null;
        temp = "        ['" + armyName + "'] =  " + Environment.NewLine;
        temp = temp + "        {" + Environment.NewLine;
        temp = temp + "            personality = ''," + Environment.NewLine;
        temp = temp + "            plans = ''," + Environment.NewLine;
        temp = temp + "            color = 0," + Environment.NewLine;
        temp = temp + "            faction = 0," + Environment.NewLine;
        temp = temp + "            Economy = { mass = 0, energy = 0,}," + Environment.NewLine;
        temp = temp + "            Alliances = {}," + Environment.NewLine;
        temp = temp + "            ['Units'] = GROUP {" + Environment.NewLine;
        temp = temp + "                orders = ''," + Environment.NewLine;
        temp = temp + "                platoon = ''," + Environment.NewLine;
        temp = temp + "                Units = {" + Environment.NewLine;
        temp = temp + "                    ['INITIAL'] = GROUP {" + Environment.NewLine;
        temp = temp + "                        orders = ''," + Environment.NewLine;
        temp = temp + "                        platoon = ''," + Environment.NewLine;
        temp = temp + "                        Units = {}," + Environment.NewLine;
        temp = temp + "                    }," + Environment.NewLine;
        temp = temp + "                }," + Environment.NewLine;
        temp = temp + "            }," + Environment.NewLine;
        temp = temp + "            PlatoonBuilders = {" + Environment.NewLine;
        temp = temp + "                next_platoon_builder_id = '0'," + Environment.NewLine;
        temp = temp + "                Builders = {}," + Environment.NewLine;
        temp = temp + "            }," + Environment.NewLine;
        temp = temp + "        }," + Environment.NewLine;
        return temp;
    }
}