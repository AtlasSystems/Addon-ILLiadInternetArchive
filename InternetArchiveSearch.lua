-- About InternetArchiveSearch.lua
--
-- Developed by Simmons College Library
--
-- Version 1.1, April 2010
--
-- InternetArchiveSearch.lua does search of Internet Archive for the LoanTitle for loans.
-- autoSearch (boolean) determines whether the search is performed automatically when a request is opened or not.
--
-- "query" is the text box name on archive.org

local autoSearch = GetSetting("AutoSearch");

local interfaceMngr = nil;
local browser = nil;

function Init()
	if GetFieldValue("Transaction", "RequestType") == "Loan" then
		interfaceMngr = GetInterfaceManager();
		
		-- Create browser
		browser = interfaceMngr:CreateBrowser("Internet Archive Search", "Internet Archive Search", "Script");
		
		-- Create buttons
		browser:CreateButton("Search", GetClientImage("Search32"), "Search", "Internet Archive");
		
		browser:Show();
		
		if autoSearch then
			Search();
		end
	end
end

function Search()
        browser:RegisterPageHandler("formExists", "searchform","SearchFormLoaded", false);
        browser:Navigate("http://archive.org");
end

function SearchFormLoaded()
		if GetFieldValue("Transaction", "RequestType") == "Loan" then
			browser:SetFormValue("searchform", "search", GetFieldValue("Transaction", "LoanTitle"));
		end
        browser:ClickObject("gobutton");
end

