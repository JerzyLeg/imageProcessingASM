using System;
using System.Reflection;


namespace ImageProccessing
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.

            //try
            //{
            //    var dllPath = @"C:\Users\ja\Desktop\politechnika\5sem\JA\projekt\ImageProccessing\x64\Debug\JALib1.dll";

            //    var assembly = Assembly.LoadFile(dllPath);

            //    var type = assembly.GetType("EdgeDetector");
            //    var obj = Activator.CreateInstance(type, 1);

            //    //constructor arguments

            //    var method = type.GetMethod("Method");

            //    var staticMethod = type.GetMethod("StaticMethod");

            //    var field = type.GetField("Int");


            //    Console.WriteLine((int)field.GetValue(obj));
            //    Console.WriteLine(method.Invoke(obj, new object[] { 2, 3 }));
            //    Console.WriteLine(staticMethod.Invoke(null, new object[] { 4, 5 }));
            //    Console.ReadLine(); 
            //}   
            //catch 
            //{ 

            //}   

            ApplicationConfiguration.Initialize();
            Application.Run(new Form1());
        }
    }
}