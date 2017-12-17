'use strict';

var bootstrap = {};
bootstrap.loadUserSettings = function () {
    Visualforce.remoting.Manager.invokeAction(RemoteActions.IsUserSettingExist, function (setting, ev) {
        if (ev.status) {
            if (ev.result == false) //Create new settings - try to derive localstorage
                {
                    Visualforce.remoting.Manager.invokeAction(RemoteActions.CreateNewUserSettingsLocStorage, localStorage.getItem(sfdcUser + '_serviceExpertLocations'), localStorage.getItem(sfdcUser + '_serviceExpertOrphan'), localStorage.getItem(sfdcUser + '_serviceExpertSettings'), localStorage.getItem(sfdcUser + '_serviceExpertFilters'), function (setting, ev) {
                        if (ev.status) {
                            bootstrap.loadedUserSettings = JSON.parse(ev.result);
                            angular.bootstrap(document.getElementById("serviceExpertApp"), ['serviceExpert']);
                        }
                    }, { buffer: false, escape: false, timeout: 120000 });
                } else //Existing settings - fetch user setting object
                {
                    Visualforce.remoting.Manager.invokeAction(RemoteActions.GetCreateUserSettings, function (setting, ev) {
                        if (ev.status) {
                            bootstrap.loadedUserSettings = JSON.parse(ev.result);
                            angular.bootstrap(document.getElementById("serviceExpertApp"), ['serviceExpert']);
                        } else {
                            bootstrap.handleError(ev);
                        }
                    }, { buffer: false, escape: false, timeout: 120000 });
                }
        } else {
            bootstrap.handleError(ev);
        }
    }, { buffer: false, escape: false, timeout: 120000 });
};

bootstrap.Start = function () {
    bootstrap.UpdatePermissionSets();
};

bootstrap.UpdatePermissionSets = function () {
    Visualforce.remoting.Manager.invokeAction(RemoteActions.updatePermissionSets, function (res, ev) {
        bootstrap.loadUserSettings();
    });
};

bootstrap.UpdatePermissionSetsBootstrap = function (DocumentName, AppName) {
    angular.bootstrap(document.getElementById(DocumentName), [AppName]);
};

bootstrap.handleError = function (ev) {
    var labelsToShowToUser = {
        no_dispatcher_license_found: true
    };

    var messageInsideLabelsToShow = false;
    for (var label in labelsToShowToUser) {
        if (customLabels[label] == ev.message) messageInsideLabelsToShow = true;
    }

    if (ev.message.toLowerCase().indexOf('dml') != -1) cantLoadGantt(customLabels.no_dispatcher_permissions_found.replace('{0}', '<a href="vf066_settings#page=0&tab=1" target="_blank">').replace('{1}', '</a>'));else if (messageInsideLabelsToShow) cantLoadGantt(ev.message);else cantLoadGantt(customLabels.dispatcher_console_error_loading);
};