#region Using declarations
using System;
using System.Net;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using System.Xml.Serialization;
using NinjaTrader.Cbi;
using NinjaTrader.Gui;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Gui.SuperDom;
using NinjaTrader.Gui.Tools;
using NinjaTrader.Data;
using NinjaTrader.NinjaScript;
using NinjaTrader.Core.FloatingPoint;
using NinjaTrader.NinjaScript.Indicators;
using NinjaTrader.NinjaScript.DrawingTools;
using System.Net.Sockets;
using System.Windows.Forms;
using System.Xml.Linq;
#endregion

//This namespace holds Strategies in this folder and is required. Do not change it. 
namespace NinjaTrader.NinjaScript.Strategies
{
    public class ocamlconnector : Strategy
    {
        private TcpClient client;
        private NetworkStream stream;
        private string HOST = "127.0.0.1";
        private int PORT = 1717;
        private int id = 0;

        protected override void OnStateChange()
        {
            if (State == State.SetDefaults)
            {
                Description = @"Enter the description for your new custom Strategy here.";
                Name = "ocamlconnector";
                Calculate = Calculate.OnPriceChange;
                EntriesPerDirection = 1;
                EntryHandling = EntryHandling.AllEntries;
                IsExitOnSessionCloseStrategy = true;
                ExitOnSessionCloseSeconds = 30;
                IsFillLimitOnTouch = false;
                MaximumBarsLookBack = MaximumBarsLookBack.TwoHundredFiftySix;
                OrderFillResolution = OrderFillResolution.Standard;
                Slippage = 0;
                StartBehavior = StartBehavior.WaitUntilFlat;
                TimeInForce = TimeInForce.Gtc;
                TraceOrders = false;
                RealtimeErrorHandling = RealtimeErrorHandling.StopCancelClose;
                StopTargetHandling = StopTargetHandling.PerEntryExecution;
                BarsRequiredToTrade = 20;
                IsInstantiatedOnEachOptimizationIteration = true;
            }
            else if (State == State.DataLoaded)
            {
                // Initialize the TCP client connection
                setup_client();
            }
            else if (State == State.Terminated)
            {
                if (stream != null) { stream.Close(); stream = null; }
                if (client != null) { client.Close(); client = null; }
            }
        }

        protected override void OnMarketData(MarketDataEventArgs e)
        {
            // Ensure the client and stream are initialized before using them
            if (client == null || stream == null) return;

            if (e.MarketDataType == MarketDataType.Last) // Process only last trades
            {
                id++;
                string message = $"{e.Time}|{e.Price}|{e.Volume}|{id}";
                Print(message);
                byte[] dataToSend = Encoding.ASCII.GetBytes(message + "\n");
                stream.Write(dataToSend, 0, dataToSend.Length);
                stream.Flush();

            }
        }

        private void setup_client()
        {
            try
            {
                client = new TcpClient(HOST, PORT);
                stream = client.GetStream();
                Print("Connected to server");
            }
            catch (Exception ex)
            {
                Print("Error connecting to server: " + ex.Message);
            }
        }
    }
}