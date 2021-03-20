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

local autoSearch = GetSetting("AutoSearch");

local interfaceMngr = nil;
local addonForm = {};

function Init()
	if GetFieldValue("Transaction", "RequestType") == "Loan" then

		interfaceMngr = GetInterfaceManager();

		-- Create a form
		addonForm.Form = interfaceMngr:CreateForm("Internet Archive Search", "Internet Archive Search");

		-- Add a browser
		addonForm.Browser = addonForm.Form:CreateBrowser("Internet Archive Search", "Internet Archive Search", "Internet Archive", "Chromium");

		-- Hide the text label
		addonForm.Browser.TextVisible = false;
		addonForm.Browser:CollapseTextPlaceholder();

		-- Since we didn't create a ribbon explicitly before creating our browser, it will have created one using the name we passed the CreateBrowser method.  
		-- We can retrieve that one and add our buttons to it.
		addonForm.RibbonPage = addonForm.Form:GetRibbonPage("Internet Archive");

		-- Create the search button
		addonForm.RibbonPage:CreateButton("Search", GetClientImage("Search32"), "Search", "Internet Archive Search");

		-- After we add all of our buttons and form elements, we can show the form.
		addonForm.Form:Show();

		if autoSearch then
			Search();
		end
	end
end

function Search()
	addonForm.Browser:RegisterPageHandler("formExists", "searchform","SearchFormLoaded", false);
	addonForm.Browser:Navigate("http://archive.org");
end

function SearchFormLoaded()	
	if GetFieldValue("Transaction", "RequestType") == "Loan" then
		SearchInternetArchives(addonForm.Browser, "searchform", "search", GetFieldValue("Transaction", "LoanTitle"));
	end	
end

function SearchInternetArchives(browser, formName, inputName, value)	
	if browser then		
		--Script to execute
		local searchInternetArchives = [[
			(function(formName, inputName, value) {
				//Write to the client log. 
				//Use ES6 Template Strings to concatenate - using back-ticks: https://developers.google.com/web/updates/2015/01/ES6-Template-Strings
				atlasAddonAsync.executeAddonFunction("LogDebug", `Performing Internet Archives Search: ${value}` );

				let form = document.forms[formName];
				if (!(form)) {
					atlasAddonAsync.executeAddonFunction("LogDebug", `Unable to find form: ${formName}` );
					return;
				}
				
				let inputElement = form.elements[inputName];
				if (!(inputElement)) {
					atlasAddonAsync.executeAddonFunction("LogDebug", `Unable to find form input: ${inputName}` );
					return;
				}
				inputElement.value = value;

				//Internet Archive masks form submit with a hidden element with name "submit"
				//Instead, look for a the button and click it
				if (form.getElementsByTagName("button").length == 1) {
					form.getElementsByTagName("button")[0].click();
				}
			})
		]];

		browser:ExecuteScript(searchInternetArchives, { formName, inputName, value });
	end
end