// ==UserScript==
// @id             PBSLM-jira-link
// @name           PBSLM Jira Link
// @version        1.0
// @namespace      rc
// @author         Radu Ciorba
// @description
// @include        https://github.com/pbs/Panda/pull/*
// @run-at         document-end
// ==/UserScript==
var root_el = document.getElementById("pull-head");
var branch_name_el = root_el.getElementsByClassName(
    "current-branch")[1].getElementsByTagName("span")[0];
var branch_name = branch_name_el.textContent.trim();
branch_name_el.innerHTML="<a href=\"https://projects.pbs.org/jira/browse/"+branch_name
    +"\">"+branch_name+"</a>";
