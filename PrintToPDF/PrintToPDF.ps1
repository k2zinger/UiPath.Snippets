param
(
	[Parameter(Mandatory)]
	[String]
	$InputFile,

	[Parameter(Mandatory)]
	[String]
	$OutputPath
)

begin
{
	# check to see whether the PDF printer was set up correctly
	#$printerName = "PrintPDFUnattended"
	$printerName = [DateTimeOffset]::Now.ToUnixTimeSeconds().ToString()
	$printer = Get-Printer -Name $printerName -ErrorAction SilentlyContinue
	if (!$?)
	{
		$TempPDF = "$env:LOCALAPPDATA\Temp\" + $printerName + ".pdf"
		$port = Get-PrinterPort -Name $TempPDF -ErrorAction SilentlyContinue
		if ($port -eq $null)
		{
			# create printer port
			Add-PrinterPort -Name $TempPDF -ErrorAction SilentlyContinue
		}

		# add printer
		Add-Printer -DriverName "Microsoft Print to PDF" -Name $printerName -PortName $TempPDF -ErrorAction SilentlyContinue
	}
	else
	{
		# this is the file the print driver always prints to
		$TempPDF = $printer.PortName
		
		# is the port name is the output file path?
		if ($TempPDF -notlike '?:\*')
		{
			throw "Printer $printerName is not set up correctly. Remove the printer, and try again."
		}
	}

	# make sure old print results are removed
	$exists = Test-Path -Path $TempPDF
	if ($exists) { Remove-Item -Path $TempPDF -Force }
	
	# create an empty arraylist that takes the piped results
	[Collections.ArrayList]$collector = @()
}

process
{
	$InputObject = Get-Content $InputFile
	$null = $collector.Add($InputObject)
}

end
{
	# send anything that is piped to this function to PDF
	$collector | Out-Printer -Name $printerName

	# wait for the print job to be completed, then move file
	$ok = $false
	do { 
		Start-Sleep -Milliseconds 500
			
		$fileExists = Test-Path -Path $TempPDF
		if ($fileExists)
		{
			try
			{
				Move-Item -Path $TempPDF -Destination $OutputPath -Force -ErrorAction Stop
				$ok = $true
			}
			catch
			{
				# file is still in use, cannot move
				# try again
			}
		}
	} until ( $ok )
	#rename file from timestamp to original file name
	$OldFile = $OutputPath + "\" + $printerName + '.pdf'
	$NewFile = [System.IO.Path]::GetFileNameWithoutExtension($InputFile) + '.pdf'
	Rename-Item -Path $OldFile -NewName $NewFile
	
	Remove-Printer -Name $printerName -ErrorAction SilentlyContinue
	Remove-PrinterPort -Name $printerName -ErrorAction SilentlyContinue
}