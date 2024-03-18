/*
 * *****************************************************************************
 * Temat: Sobel operator
 * Semestr: Zimowy, Rok: 2023/2024
 * Autor: Jerzy Legaszewski
 *
 * Algorytm s³u¿y do wykrywania krawêdzi. Sk³ada siê z 3 procedur:
 * 1) obliczeniu gradientu poziomego
 *
 *         |1  0  -1|
 *    Gx = |2  0  -2| * A
 *         |1  0  -1|
 *
 *
 * 2) obliczenie gradientu pionowego
 *
 *         | 1  2  1|
 *    Gy = | 0  0  0| * A
 *         |-1 -2 -1|
 *
 *
 * 3) obliczenie gradientu wynikowego
 *
 *    G = |Gx| + |Gy|
 *
 * *****************************************************************************
 */

using System.Drawing;
using System.Runtime.InteropServices;
using System.Drawing.Imaging;
using System.IO;
using System.Collections.Specialized;
using System;
using System.Diagnostics;

namespace ImageProccessing
{
    public struct RColor
    {
        byte r;
        public RColor(Color c)
        {
            r = c.R;
        }
        public byte getR()
        {
            return this.r;
        }
    }
    public partial class Form1 : Form
    {

        private ImageData imageData; // Class to hold the image data


        public Form1()
        {
            InitializeComponent();
            imageData = new ImageData();

            this.FormBorderStyle = FormBorderStyle.FixedSingle;
            this.MinimizeBox = false;
            this.MaximizeBox = false;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            //MyProc(5,10)
        }

        [DllImport("C:\\Users\\ja\\Desktop\\politechnika\\5sem\\JA\\projekt\\ImageProccessing\\x64\\Debug\\JaLIb1.dll")]
        public static extern void applyColorR(RColor[] inputImage, int width, int height, byte[] outputImage);


        [DllImport("C:\\Users\\ja\\Desktop\\politechnika\\5sem\\JA\\projekt\\ImageProccessing\\x64\\Debug\\JaLIb1.dll")]
        private static extern void MyTestFunction(RColor[] inputImage, byte[] outputImage, int width, int height);

        [DllImport("C:\\Users\\ja\\Desktop\\politechnika\\5sem\\JA\\projekt\\ImageProccessing\\x64\\Debug\\JaLIb1.dll")]
        private static extern void GradientX(IntPtr inputImage, short[] outputImage, int width, int height);

        [DllImport("C:\\Users\\ja\\Desktop\\politechnika\\5sem\\JA\\projekt\\ImageProccessing\\x64\\Debug\\JaLIb1.dll")]
        private static extern void GradientY(IntPtr inputImage, short[] outputImage, int width, int height);

        [DllImport("C:\\Users\\ja\\Desktop\\politechnika\\5sem\\JA\\projekt\\ImageProccessing\\x64\\Debug\\JaLIb1.dll")]
        private static extern void Fusion(IntPtr array1, IntPtr array2, byte[] resultArray, int size);



        public Color[] convertBitmapToPixelArray(Bitmap bmp)
        {
            Color[] pixelArray = new Color[bmp.Width * bmp.Height];
            for (int y = 0; y < bmp.Height; y++)
            {
                for (int x = 0; x < bmp.Width; x++)
                {
                    pixelArray[y * bmp.Width + x] = bmp.GetPixel(x, y);
                }
            }
            return pixelArray;
        }

        public RColor[] convertColorArrayToRColorArray(Color[] colorArray)
        {
            RColor[] rColorArray = new RColor[colorArray.Length];
            for (int i = 0; i < colorArray.Length; i++)
            {
                rColorArray[i] = new RColor(colorArray[i]);
            }
            return rColorArray;
        }

        public static Bitmap BytesToBitmap(byte[] imageData, int rows, int columns)
        {
            int currentStride = columns; 
            int newStride = columns;
            byte[] newBytes = new byte[newStride * rows];
            for (int i = 0; i < rows; i++)
            {
                Buffer.BlockCopy(imageData, currentStride * i, newBytes, newStride * i, currentStride);
            }

            Bitmap bmp = new Bitmap(columns, rows, columns,PixelFormat.Format8bppIndexed,Marshal.UnsafeAddrOfPinnedArrayElement(newBytes, 0));
            return bmp;
        }

        public static Bitmap MatrixToGrayImage(Byte[] matrix, Int32 width, Int32 height)
        {
            // Create a new 8bpp bitmap
            Bitmap bmp = new Bitmap(width, height, PixelFormat.Format8bppIndexed);
            // Get the backing data
            BitmapData data = bmp.LockBits(new Rectangle(0, 0, width, height), ImageLockMode.WriteOnly, PixelFormat.Format8bppIndexed);
            Int32 dataOffset = 0;
            Int64 scanPtr = data.Scan0.ToInt64();
            // Copy the contents of your matrix into the image, line by line.
            for (Int32 y = 0; y < height; ++y)
            {
                Marshal.Copy(matrix, dataOffset, new IntPtr(scanPtr), width);
                // Increase input pos by the width, and pos output by the stride.
                dataOffset += width;
                scanPtr += data.Stride;
            }
            bmp.UnlockBits(data);
            // Get the original palette. Note that this makes a COPY of the ColorPalette object.
            ColorPalette pal = bmp.Palette;
            // Generate grayscale colours:
            for (Int32 i = 0; i < 256; ++i)
                pal.Entries[i] = Color.FromArgb(i, i, i);
            // Assign the edited palette to the bitmap.
            bmp.Palette = pal;
            return bmp;
        }


        public Bitmap greyscale(Bitmap bmp)
        {
            for (int i = 0; i < bmp.Width; i++)
            {
                for (int j = 0; j < bmp.Height; j++)
                {
                    Color bmpColor = bmp.GetPixel(i, j);
                    int red = bmpColor.R;
                    int green = bmpColor.G;
                    int blue = bmpColor.B;
                    int gray = (byte)(.299 * red + .587 * green + .114 * blue);

                    bmp.SetPixel(i, j, Color.FromArgb(gray, gray, gray));
                }
            }
            return bmp;
        }
        private void ShowImageForm(Bitmap image, int width, int height)
        {
            Form imageForm = new Form();
            PictureBox pictureBox = new PictureBox();

            // Set properties for the PictureBox
            pictureBox.Dock = DockStyle.Fill;
            pictureBox.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBox.Image = image;

            // Set properties for the Form
            imageForm.Text = "Image Preview";
            imageForm.Size = new Size(width, height); // Set the same size as the image
            imageForm.Controls.Add(pictureBox);

            // Show the new form
            imageForm.Show();
        }



        private void button1_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                imageData.SetOriginalImage(new Bitmap(ofd.FileName));

                // Display the selected image in a new form with the same size
                ShowImageForm(imageData.OriginalImage, imageData.OriginalWidth, imageData.OriginalHeight);
            }
        }

        private void button2_Click_1(object sender, EventArgs e)
        {
            bool cpp = false;
            bool asm = false;
            if (imageData.HasOriginalImage)
            {
                Bitmap bmp = greyscale(imageData.OriginalImage);
                //Bitmap bmp = imageData.OriginalImage;
                Color[] colorMap = convertBitmapToPixelArray(bmp);

                int width = imageData.OriginalWidth;
                int height = imageData.OriginalHeight;
                int size = width * height;

                // Dynamically allocate the resultArray based on the image dimensions
                var resultArray = new byte[width * height];
                var resultGx = new short[width * height];
                var resultGy = new short[width * height];


                RColor[] RColorMap = convertColorArrayToRColorArray(colorMap);

                var timer = new Stopwatch();

                if (radioButton1.Checked)
                {
                    if (imageData.HasOriginalImage)
                    {
                        timer.Start();
                        applyColorR(RColorMap, width, height, resultArray);
                        timer.Stop();
                        cpp = true;
                    }
                }
                else if (radioButton2.Checked)
                {
                    if (imageData.HasOriginalImage)
                    {
                        var byteArray = new byte[width * height];


                        for (int i =0; i < RColorMap.Length; i++)
                        {
                            byteArray[i] = RColorMap[i].getR();
                        }

                        IntPtr ptr = Marshal.AllocHGlobal(byteArray.Length);
                        Marshal.Copy(byteArray, 0, ptr, byteArray.Length);

                        timer.Start();
                        GradientX(ptr, resultGx, width, height);
                        GradientY(ptr, resultGy, width, height);

                        int shortLength = resultGx.Length * sizeof(short);
                        IntPtr ptrX = Marshal.AllocHGlobal(shortLength);
                        Marshal.Copy(resultGx, 0, ptrX, resultGx.Length);

                        IntPtr ptrY = Marshal.AllocHGlobal(shortLength);
                        Marshal.Copy(resultGy, 0, ptrY, resultGy.Length);

                        Fusion(ptrX, ptrY, resultArray, size);
                        timer.Stop();

                        Marshal.FreeHGlobal(ptr);
                        Marshal.FreeHGlobal(ptrX);
                        Marshal.FreeHGlobal(ptrY);

                        asm = true;
                    }
                }
                Bitmap resultBitmap = MatrixToGrayImage(resultArray, width, height);

                // Store the processed image in the ImageData class
                imageData.SetProcessedImage(resultBitmap);

                // Display the processed image in a new form with the same size
                ShowImageForm(resultBitmap, width, height);

                TimeSpan timeTaken = timer.Elapsed;
                if (cpp)
                {
                    MessageBox.Show($"CPP Time: {timeTaken.TotalSeconds} seconds");
                    cpp = false;
                }

                if(asm)
                {
                    MessageBox.Show($"ASM Time: {timeTaken.TotalSeconds} seconds");
                    asm = false;
                }
            }
            else
            {
                MessageBox.Show("Please select an image first.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void radioButton2_CheckedChanged(object sender, EventArgs e)
        {

            RadioButton? selectedRadioButton = sender as RadioButton;

            if (selectedRadioButton != null && selectedRadioButton.Checked)
            {
                if (selectedRadioButton == radioButton1)
                {
                    radioButton2.Checked = false;
                }
                else if (selectedRadioButton == radioButton2)
                {
                    radioButton1.Checked = false;
                }
            }

        }
    }
    public class ImageData
    {
        public Bitmap? OriginalImage { get; private set; }
        public int OriginalWidth => OriginalImage?.Width ?? 0;
        public int OriginalHeight => OriginalImage?.Height ?? 0;

        public Bitmap? ProcessedImage { get; private set; }

        public bool HasOriginalImage => OriginalImage != null;

        public void SetOriginalImage(Bitmap image)
        {
            OriginalImage = image;
            ProcessedImage = null; // Reset processed image when setting a new original image
        }

        public void SetProcessedImage(Bitmap image)
        {
            ProcessedImage = image;
        }
    }



}