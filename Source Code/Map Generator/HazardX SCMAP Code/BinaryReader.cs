// ***************************************************************************************
// * SCMAP Loader
// * Copyright Unknown
// * Filename: BinaryReader.cs
// * Source: http://www.hazardx.com/details.php?file=82
// ***************************************************************************************


using SlimDX;
using System;

public class BinaryReader : System.IO.BinaryReader
{

    public BinaryReader(System.IO.Stream Stream)
        : base(Stream)
    {
    }

    public Vector2 ReadVector2()
    {
        Vector2 v = new Vector2();
        v.X = ReadSingle();
        v.Y = ReadSingle();
        return v;
    }

    public Vector3 ReadVector3()
    {
        Vector3 v = new Vector3();
        v.X = ReadSingle();
        v.Y = ReadSingle();
        v.Z = ReadSingle();
        return v;
    }

    public Vector4 ReadVector4()
    {
        Vector4 v = new Vector4();
        v.X = ReadSingle();
        v.Y = ReadSingle();
        v.Z = ReadSingle();
        v.W = ReadSingle();
        return v;
    }

    public string ReadString(int Length)
    {
        return System.Text.Encoding.ASCII.GetString(ReadBytes(Length));
    }

    public string ReadStringNull()
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        byte val = 0;
        do
        {
            val = ReadByte();
            if (val == 0)
                break;
            sb.Append((char)val);
        } while (true);
        return sb.ToString();
    }

    public short[] ReadInt16Array(int Count)
    {
        short[] ary = new short[Count];
        for (int i = 0; i <= Count - 1; i++)
        {
            ary[i] = ReadInt16();
        }
        return ary;
    }

    public int[] ReadInt32Array(int Count)
    {
        int[] ary = new int[Count];
        for (int i = 0; i <= Count - 1; i++)
        {
            ary[i] = ReadInt32();
        }
        return ary;
    }

    public void SeekNull()
    {
        while (!(ReadByte() == 0))
        {
        }
    }
    public void SeekSkipNull()
    {
        SeekNull();
        BaseStream.Position += 1;
    }

}