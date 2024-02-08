using Microsoft.Office.Interop.Excel;
using Microsoft.Office.Interop.Word;
using PrintToPDF.ObjectRepository;
using System;
using System.Activities;
using System.Collections.Generic;
using System.Data;
using UiPath.CodedWorkflows;
using UiPath.Core;
using UiPath.Core.Activities.Storage;
using UiPath.Excel;
using UiPath.Excel.Activities;
using UiPath.Excel.Activities.API;
using UiPath.Excel.Activities.API.Models;
using UiPath.Orchestrator.Client.Models;
using UiPath.UIAutomationNext.API.Contracts;
using UiPath.UIAutomationNext.API.Models;
using UiPath.UIAutomationNext.Enums;

namespace PrintToPDF
{
    public class PrintToPDF : CodedWorkflow
    {
       
        [Workflow]
        public void Execute(string fileName, string outputFile)
        {
            // To start using services, use IntelliSense (CTRL + Space) to discover the available services:
            // e.g. system.GetAsset(...)

            // For accessing UI Elements from Object Repository, you can use the Descriptors class e.g:
            // var screen = uiAutomation.Open(Descriptors.MyApp.FirstScreen);
            // screen.Click(Descriptors.MyApp.FirstScreen.SettingsButton);

            var extension = fileName.ToLower();
            if(extension.EndsWith("doc") || extension.EndsWith("docx"))
            {
                Microsoft.Office.Interop.Word.Application app = new Microsoft.Office.Interop.Word.Application();
                Microsoft.Office.Interop.Word.Document doc = new Microsoft.Office.Interop.Word.Document();
                
                doc = app.Documents.Open(fileName);
                doc.SaveAs2(FileName: outputFile, FileFormat: Microsoft.Office.Interop.Word.WdSaveFormat.wdFormatPDF);
                doc.Close();
                app.Quit();    
            } else if(extension.EndsWith("xls") || extension.EndsWith("xlsx"))
            {
                Microsoft.Office.Interop.Excel.Application app = new Microsoft.Office.Interop.Excel.Application();
                Microsoft.Office.Interop.Excel.Workbook doc = app.Workbooks.Add();
    
                doc = app.Workbooks.Open(fileName);
                doc.ExportAsFixedFormat(XlFixedFormatType.xlTypePDF, outputFile);
                doc.Close();
                app.Quit();
            } else
            {
                throw new Exception("unknown file type");
            }
        }
    }
}