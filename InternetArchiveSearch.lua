-- About InternetArchiveSearch.lua
--
-- Developed by Atlas Systems and Simmons College Library

-- Version 2.0.0, March 2021, Atlas Systems, Inc.
-- * Converted addon to use Chromium-based browsers
--
-- Version 1.1, April 2010, Simmons College Library
--
-- InternetArchiveSearch.lua does search of Internet Archive for the LoanTitle for loans.
-- autoSearch (boolean) determines whether the search is performed automatically when a request is opened or not.

----
---- Initial setup to open a new process (default browser)
-- Load the .NET System Assembly
luanet.load_assembly("System");
Types = {};
--Store the Process type to instantiate a new process later
Types["Process"] = luanet.import_type("System.Diagnostics.Process");
----


local autoSearch = GetSetting("AutoSearch");

local interfaceMngr = nil;
local addonForm = {};

function Init()
	if GetFieldValue("Transaction", "RequestType") == "Loan" then

		interfaceMngr = GetInterfaceManager();

		-- Create a form
		addonForm.Form = interfaceMngr:CreateForm("Internet Archive Search", "Internet Archive Search");

		-- Ensures backwards compatibility with ILLiad 9.1.
		if AddonInfo.Browsers and AddonInfo.Browsers.WebView2 then
			addonForm.Browser = addonForm.Form:CreateBrowser("Internet Archive Search", "Internet Archive Search", "Internet Archive", "WebView2");
		else
			addonForm.Browser = addonForm.Form:CreateBrowser("Internet Archive Search", "Internet Archive Search", "Internet Archive", "Chromium");
		end

		-- Hide the text label
		addonForm.Browser.TextVisible = false;
		addonForm.Browser:CollapseTextPlaceholder();

		-- Since we didn't create a ribbon explicitly before creating our browser, it will have created one using the name we passed the CreateBrowser method.  
		-- We can retrieve that one and add our buttons to it.
		addonForm.RibbonPage = addonForm.Form:GetRibbonPage("Internet Archive");

		-- Create the search button
		addonForm.RibbonPage:CreateButton("Search", GetClientImage("Search32"), "Search", "Internet Archive");
		addonForm.RibbonPage:CreateButton("Open New Browser", GetClientImage("Web32"), "OpenInDefaultBrowser", "Utility");
	
		-- After we add all of our buttons and form elements, we can show the form.
		addonForm.Form:Show();

		if autoSearch then
			LogDebug("AutoSearch is enabled.");
			Search();
		else
			LogDebug("AutoSearch is disabled. Showing Internet Archive base page");
			addonForm.Browser:Navigate("https://archive.org");
		end
	else
		LogDebug("Internet Archive Search addon not displayed. Addon is only show for Loan requests.");
	end
end

function Search()
	local searchUrl = "https://archive.org/search.php?query=" .. UrlEncode(GetFieldValue("Transaction", "LoanTitle"));
	addonForm.Browser:Navigate(searchUrl);
end

function UrlEncode(s)
	if (s) then
		s = string.gsub(s, "\n", "\r\n")
		s = string.gsub(s, "([^%w %-%_%.%~])",
			function (c)
				return string.format("%%%02X", string.byte(c))
			end);
		s = string.gsub(s, " ", "+")
	end
	return s
end

function OpenInDefaultBrowser()
	local currentUrl = addonForm.Browser.Address;
	
	if (currentUrl and currentUrl ~= "")then
		LogDebug("Opening Browser URL in default browser: " .. currentUrl);

		local process = Types["Process"]();
		process.StartInfo.FileName = currentUrl;
		process.StartInfo.UseShellExecute = true;
		process:Start();
	end
end