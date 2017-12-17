'use strict';

(function () {
    angular.module('serviceExpert').factory('sfdcService', ['$q', '$rootScope', 'userSettingsManager', function ($q, $rootScope, userSettingsManager) {
        var sfdc = {
            servicesArray: [],
            servicesObjs: {},
            activeRequests: { active: 0 },
            firstTimeGettingEmployees: function firstTimeGettingEmployees() {
                return _firstTimeGettingEmployees;
            }
        };

        var lastModifiedDate = null,
            _firstTimeGettingEmployees = $q.defer();

        // get resources, grouped to locations
        sfdc.getEmployeesByLocation = function () {
            var deferred = $q.defer();

            if (sfdc.resourcesUntouched) {
                deferred.resolve(angular.copy(sfdc.resourcesUntouched));
                return deferred.promise;
            }

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getEmployeesByLocations, function (emps, ev) {
                if (ev.status) {
                    sfdc.resources = emps;
                    sfdc.resourcesUntouched = angular.copy(emps);
                    sfdc.activeRequests.active -= 1;
                    deferred.resolve(emps);
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: true, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getUnPrivilegeUserSettingsFields = function () {
            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getUnPrivilegeUserSettingsFields, function (res, ev) {
                if (ev.status) {
                    sfdc.activeRequests.active -= 1;
                    deferred.resolve(res);
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: true, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getAllFormulaFields = function () {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getAllFormulaFields, function (fieldsMap, ev) {
                if (ev.status) {
                    sfdc.activeRequests.active -= 1;
                    deferred.resolve(fieldsMap);
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        var getServiceListFieldsDeferred = null;

        sfdc.getServiceListFields = function () {

            if (getServiceListFieldsDeferred == null) {
                getServiceListFieldsDeferred = $q.defer();

                sfdc.activeRequests.active += 1;

                Visualforce.remoting.Manager.invokeAction(RemoteActions.getServiceListFields, function (fieldsList, ev) {
                    if (ev.status) {
                        sfdc.activeRequests.active -= 1;
                        getServiceListFieldsDeferred.resolve(fieldsList);
                    } else {
                        sfdc.activeRequests.active -= 1;
                        getServiceListFieldsDeferred.reject(ev);
                    }
                }, { buffer: false, escape: false, timeout: 120000 });
            }
            return getServiceListFieldsDeferred.promise;
        };

        var getGanttToolTipDeferred = null;

        sfdc.getGanttToolTipFields = function () {

            if (getGanttToolTipDeferred == null) {
                getGanttToolTipDeferred = $q.defer();

                sfdc.activeRequests.active += 1;

                Visualforce.remoting.Manager.invokeAction(RemoteActions.getServiceGanttTooltipFields, function (fieldsList, ev) {
                    if (ev.status) {
                        sfdc.activeRequests.active -= 1;
                        getGanttToolTipDeferred.resolve(fieldsList);
                    } else {
                        sfdc.activeRequests.active -= 1;
                        getGanttToolTipDeferred.reject(ev);
                    }
                }, { buffer: false, escape: false, timeout: 120000 });
            }
            return getGanttToolTipDeferred.promise;
        };

        var getServiceMiniFormFieldsDeferred = null;

        sfdc.getServiceMiniFormFields = function () {

            if (getServiceMiniFormFieldsDeferred == null) {
                getServiceMiniFormFieldsDeferred = $q.defer();

                sfdc.activeRequests.active += 1;

                Visualforce.remoting.Manager.invokeAction(RemoteActions.getServiceMiniFormFields, function (fieldsList, ev) {
                    if (ev.status) {
                        sfdc.activeRequests.active -= 1;
                        getServiceMiniFormFieldsDeferred.resolve(fieldsList);
                    } else {
                        sfdc.activeRequests.active -= 1;
                        getServiceMiniFormFieldsDeferred.reject(ev);
                    }
                }, { buffer: false, escape: false, timeout: 120000 });
            }
            return getServiceMiniFormFieldsDeferred.promise;
        };

        var getServiceMapInfoWindowFieldsDeferred = null;

        sfdc.getServiceMapInfoWindowFields = function () {

            if (getServiceMapInfoWindowFieldsDeferred == null) {
                getServiceMapInfoWindowFieldsDeferred = $q.defer();

                sfdc.activeRequests.active += 1;

                Visualforce.remoting.Manager.invokeAction(RemoteActions.getServiceMapInfoWindowFields, function (fieldsList, ev) {
                    if (ev.status) {
                        sfdc.activeRequests.active -= 1;
                        getServiceMapInfoWindowFieldsDeferred.resolve(fieldsList);
                    } else {
                        sfdc.activeRequests.active -= 1;
                        getServiceMapInfoWindowFieldsDeferred.reject(ev);
                    }
                }, { buffer: false, escape: false, timeout: 120000 });
            }
            return getServiceMapInfoWindowFieldsDeferred.promise;
        };

        var getServiceCapacityColumnsDeferred = null;

        sfdc.getServiceCapacityColumns = function () {

            if (getServiceCapacityColumnsDeferred == null) {
                getServiceCapacityColumnsDeferred = $q.defer();

                sfdc.activeRequests.active += 1;

                Visualforce.remoting.Manager.invokeAction(RemoteActions.getServiceCapacityColumns, function (fieldsList, ev) {
                    if (ev.status) {
                        sfdc.activeRequests.active -= 1;
                        getServiceCapacityColumnsDeferred.resolve(fieldsList);
                    } else {
                        sfdc.activeRequests.active -= 1;
                        getServiceCapacityColumnsDeferred.reject(ev);
                    }
                }, { buffer: false, escape: false, timeout: 120000 });
            }
            return getServiceCapacityColumnsDeferred.promise;
        };

        // get policies
        sfdc.getPolicies = function () {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getPolicies, function (polices, ev) {
                if (ev.status) {
                    sfdc.activeRequests.active -= 1;
                    deferred.resolve(polices);
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.sortServicesByPriority = function (servicesIds) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.sortServicesByPriority, servicesIds, function (sortedIds, ev) {
                if (ev.status) {
                    sfdc.activeRequests.active -= 1;
                    deferred.resolve(sortedIds);
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // check rule violations
        sfdc.checkRules = function (servicesIds, policyId) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            if (!$rootScope.policy) $rootScope.policy = null;

            if (!policyId) policyId = $rootScope.policy;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.checkRules, servicesIds, policyId, function (violations, ev) {
                if (ev.status) {
                    sfdc.activeRequests.active -= 1;
                    deferred.resolve(violations);
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        //return the delta updates
        sfdc.getDelta = function (lastModifiedDate) {

            var deferred = $q.defer();

            var filteredLocations = getFilteredLocations();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getDelta, lastModifiedDate, filteredLocations, function (servicesDelta, event) {
                if (event.status) {
                    deferred.resolve(servicesDelta);
                } else {
                    deferred.reject(event);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // write on feed
        sfdc.postToChatter = function (servicesIdsArray, sayWhat) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.postToChatter, servicesIdsArray, sayWhat, function (numOfMentions, ev) {
                if (ev.status) {
                    sfdc.activeRequests.active -= 1;
                    deferred.resolve(numOfMentions);
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getLivePositions = function () {
            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            var filteredLocations = getFilteredLocations();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getLivePositions, filteredLocations, function (livePositions, event) {
                if (event.status) {
                    deferred.resolve(livePositions);
                    sfdc.activeRequests.active -= 1;
                } else {
                    deferred.reject(event);
                    sfdc.activeRequests.active -= 1;
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        function getFilteredLocations() {
            var locations = userSettingsManager.GetUserSettingsProperty('locations');

            if (locations) return locations;

            return [];
        }

        function getOrphanServices() {
            return JSON.parse(userSettingsManager.GetUserSettingsProperty('Show_Orphan_Services__c'));
        }

        sfdc.getSlots = function (serviceId, policyId) {
            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getSlots, serviceId, policyId, function (slots, event) {

                var result = {};
                result.value = slots;
                result.eventType = event.type;

                if (event.type == 'exception') {
                    result.event = event;
                    deferred.resolve(result);
                    sfdc.activeRequests.active -= 1;
                }

                if (event.status) {
                    deferred.resolve(result);
                    sfdc.activeRequests.active -= 1;
                } else {
                    deferred.reject(event);
                    sfdc.activeRequests.active -= 1;
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getSkills = function () {

            var deferred = $q.defer();
            var filteredLocations = getFilteredLocations();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getSkills, function (skills, ev) {

                if (ev.status) {
                    deferred.resolve(skills);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getPolygons = function () {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getPolygons, function (polygons, ev) {

                if (ev.status) {
                    deferred.resolve(polygons);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.savePolygon = function (path, color, name, territory, polyId) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.savePolygon, path, color, name, territory, polyId, function (polygon, ev) {

                if (ev.status) {
                    deferred.resolve(polygon);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.deletePolygon = function (polyId) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.deletePolygon, polyId, function (polygon, ev) {

                if (ev.status) {
                    deferred.resolve(polygon);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getLocale = function () {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getLocale, function (local, ev) {

                if (ev.status) {
                    deferred.resolve(local);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.autoScheduleService = function (serviceId, policyId) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.autoScheduleService, serviceId, policyId, function (result, ev) {
                if (ev.status) {
                    deferred.resolve(result);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getDictionaries = function () {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getDictionaries, function (dictionaries, ev) {
                if (ev.status) {
                    deferred.resolve(dictionaries);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.unscheduleServicesByServicesId = function (ids) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;
            Visualforce.remoting.Manager.invokeAction(RemoteActions.unscheduleServicesByServicesId, ids, function (unscheduledServices, ev) {
                if (ev.status) {
                    deferred.resolve(unscheduledServices);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.unscheduleServicesByLocationsId = function (ids, start, finish) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.unscheduleServicesByLocationsId, ids, start, finish, function (unscheduledServices, ev) {
                if (ev.status) {
                    deferred.resolve(unscheduledServices);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getLocationsCurrentTime = function (ids, start, finish) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getLocationsCurrentTime, function (currentTimes, ev) {
                if (ev.status) {
                    deferred.resolve(currentTimes);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.changeStatusesByServicesId = function (ids, status) {
            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.changeStatusesByServicesId, ids, status, function (changedStatuses, ev) {
                if (ev.status) {
                    deferred.resolve(changedStatuses);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.changeStatusesByLocations = function (ids, start, finish, status, includeContractorServices) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.changeStatusesByLocations, ids, start, finish, status, includeContractorServices, function (changedStatuses, ev) {
                if (ev.status) {
                    deferred.resolve(changedStatuses);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.keepAlive = function () {

            Visualforce.remoting.Manager.invokeAction(RemoteActions.keepAlive, function (result, event) {
                if (event.status) {} else if (event.type === 'exception') {
                    if (event.message.indexOf('Logged in') > -1) {
                        // This is it !! user is not logged in.. probably
                        alert(customLabels.sessionTimedOut);
                        location.reload();
                    }
                } else {
                    console.log(customLabels.failed_to_refresh);
                }
            }, { buffer: false, escape: false, timeout: 120000 });
        };

        //setInterval(sfdc.keepAlive, 60000);


        sfdc.getStatuses = function () {
            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getStatuses, function (statuses, ev) {
                if (ev.status) {
                    deferred.resolve(statuses);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getEmployeeAbsenceTypes = function () {
            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getEmployeeAbsenceTypes, function (eaTypes, ev) {
                if (ev.status) {
                    deferred.resolve(eaTypes);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getWorkOrderPriority = function () {
            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getWorkOrderPriority, function (woPriorities, ev) {
                if (ev.status) {
                    deferred.resolve(woPriorities);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getReports = function () {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getReportsWithGeolocationCols, function (reports, ev) {
                if (ev.status) {
                    deferred.resolve(reports);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getReportRowsForMap = function (reportId) {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getReportRowsForMap, reportId, function (reportRows, ev) {
                if (ev.status) {
                    deferred.resolve(reportRows);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.runOptimization = function (start, finish, locationsIds, optimizeAll, orphan, policyId, filterField) {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.runOptimization, start, finish, locationsIds, optimizeAll, orphan, policyId, filterField, function (optimizaionId, ev) {
                if (ev.status) {
                    deferred.resolve(optimizaionId);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getRequestObject = function (requestId) {
            var deferred = $q.defer();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getRequestObject, requestId, function (reqId, ev) {
                if (ev.status) {
                    deferred.resolve(reqId);
                } else {
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getCustomizationFiles = function () {

            var deferred = $q.defer();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getCustomizationFiles, function (files, ev) {
                if (ev.status) {
                    deferred.resolve(files);
                } else {
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // get services in range
        sfdc.getShiftsInRange = function (start, end, lastModified) {

            var deferred = $q.defer();
            var filteredLocations = getFilteredLocations();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getShifts, start, end, filteredLocations, function (services, ev) {
                if (ev.status) {
                    deferred.resolve(services);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getOptimizationsRequest = function () {

            var deferred = $q.defer();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getOptimizationsRequest, function (opt_running, ev) {
                if (ev.status) {
                    deferred.resolve(opt_running);
                } else {
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // will save a single service to sfdc
        sfdc.saveChangesToBreak = function (breakId, resourceId, start, end, snapTo) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            var filteredLocations = getFilteredLocations();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.saveChangesToBreak, breakId, resourceId, start, end, snapTo, function (myBreak, ev) {
                if (ev.status) {
                    sfdc.activeRequests.active -= 1;
                    deferred.resolve(myBreak);
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.deleteBreak = function (breakId) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            var filteredLocations = getFilteredLocations();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.deleteBreak, breakId, function (isDeleted, ev) {
                if (ev.status) {
                    sfdc.activeRequests.active -= 1;
                    deferred.resolve(isDeleted);
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getResourceFieldSetFields = function () {

            var deferred = $q.defer();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getResourceFieldSetFields, function (resourceFieldset, ev) {
                if (ev.status) {
                    deferred.resolve(resourceFieldset);
                } else {
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getStatusTranslations = function () {

            var deferred = $q.defer();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getStatusTranslations, function (statusTranslations, ev) {
                if (ev.status) {
                    deferred.resolve(statusTranslations);
                } else {
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // ************************************************************************************************************
        // ************************************************************************************************************
        // *********************************** NEW STUFF FOR NEW DATA MODEL STUFF *************************************
        // ************************************************************************************************************
        // ************************************************************************************************************


        sfdc.getResourcePicklistValues = function (fieldsArray) {

            var deferred = $q.defer();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getResourcePicklistValues, fieldsArray, function (resourceFieldset, ev) {
                if (ev.status) {
                    deferred.resolve(resourceFieldset);
                } else {
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // Get all recouces that are related to the given territories IDs
        // If none is given, the server will return all of them
        sfdc.GetResourcesAndTerritories = function (territoriesIds) {
            var deferred = $q.defer();

            Visualforce.remoting.Manager.invokeAction(RemoteActions.GetResourcesAndTeritorries, territoriesIds || getFilteredLocations(), function (resources, ev) {
                if (ev.status) {
                    deferred.resolve(resources);
                } else {
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // Get all recouces that are related to the given territories IDs
        // If none is given, the server will return all of them
        sfdc.GetTimePhasedObjects = function (startDateStr, finishDateStr, territories) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.GetTimePhasedObjects, startDateStr, finishDateStr, territories || getFilteredLocations(), function (timePhasedObjects, ev) {
                sfdc.activeRequests.active -= 1;
                if (ev.status) {
                    deferred.resolve(timePhasedObjects);
                } else {
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // get service appointments to service list by end date and back horizon
        sfdc.loadServiceAppointmentsToList = function (end, numOfDays, toLoad, inRange) {

            var deferred = $q.defer();
            var orphan = getOrphanServices();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.LoadServiceAppointmentsToServiceList, end, getFilteredLocations(), orphan, numOfDays, toLoad, inRange, function (services, ev) {
                if (ev.status) {
                    deferred.resolve(services);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.saveChangesToAbsence = function (id, resourceId, startDateStr, finishDateStr, type) {
            var label = arguments.length > 5 && arguments[5] !== undefined ? arguments[5] : null;


            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.saveChangesToAbsence, id, resourceId, startDateStr, finishDateStr, type, label, function (absence, ev) {
                if (ev.status) {
                    deferred.resolve(absence);
                    sfdc.activeRequests.active -= 1;
                } else {
                    deferred.reject(ev);
                    sfdc.activeRequests.active -= 1;
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // (Id newResourceId, Id currentAssignedResourceId, Id serviceAppointmentId, String strStartDate, String strFinishDate)
        sfdc.saveChangesToServiceAppointment = function (serviceAppointmentId, newResourceId, currentAssignedResourceId, strStartDate, strFinishDate, usedPolicyId, scheduleMode) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.saveChangesToServiceAppointment, serviceAppointmentId, newResourceId, currentAssignedResourceId, strStartDate, strFinishDate, usedPolicyId, scheduleMode, function (absence, ev) {
                if (ev.status) {
                    deferred.resolve(absence);
                    sfdc.activeRequests.active -= 1;
                } else {
                    deferred.reject(ev);
                    sfdc.activeRequests.active -= 1;
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // dispatch by service id
        sfdc.changeStatusServicesByServicesId = function (ids, status) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;
            Visualforce.remoting.Manager.invokeAction(RemoteActions.changeStatusServicesByServicesId, ids, status, function (services, ev) {
                if (ev.status) {
                    deferred.resolve(services);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        // dispatch by location id
        sfdc.changeStatusServicesByLocationsId = function (ids, status, start, finish) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.changeStatusServicesByLocationsId, ids, status, start, finish, function (servoces, ev) {
                if (ev.status) {
                    deferred.resolve(servoces);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.deleteResourceAbsence = function (id) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.deleteResourceAbsence, id, function (deleteResult, ev) {
                if (ev.status) {
                    deferred.resolve(deleteResult);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getStatusFlow = function () {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getStatusFlow, function (statusFlow, ev) {
                if (ev.status) {
                    deferred.resolve(statusFlow);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getStatuses = function () {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getStatuses, function (statusFlow, ev) {
                if (ev.status) {
                    deferred.resolve(statusFlow);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.changePin = function (services, newPin) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.changePins, services, newPin, function (services, ev) {
                if (ev.status) {
                    deferred.resolve(services);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.setServiceAppointmentsInJeopardy = function (services) {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.setServiceAppointmentsInJeopardy, services, function (services, ev) {
                if (ev.status) {
                    deferred.resolve(services);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getOptimizationRequests = function () {

            var deferred = $q.defer();
            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getOptimizationRequests, getFilteredLocations(), getOrphanServices(), function (requests, ev) {
                if (ev.status) {
                    deferred.resolve(requests);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.runFillInSchedule = function (start, resourceId, policyId) {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.runFillInSchedule, start, resourceId, policyId, function (jobId, ev) {
                if (ev.status) {
                    deferred.resolve(jobId);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.runFixOverlaps = function (start, resourceId, policyId) {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.runFixOverlaps, start, resourceId, policyId, function (jobId, ev) {
                if (ev.status) {
                    deferred.resolve(jobId);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.runGroupNearby = function (serviceId, policyId) {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.runGroupNearby, serviceId, policyId, function (jobId, ev) {
                if (ev.status) {
                    deferred.resolve(jobId);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.runReshuffle = function (serviceId, policyId) {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.runReshuffle, serviceId, policyId, function (jobId, ev) {
                if (ev.status) {
                    deferred.resolve(jobId);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getResourceActualRoute = function (resourceId, date) {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getResourceActualRoute, resourceId, date, function (actual, ev) {
                if (ev.status) {
                    deferred.resolve(actual);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getFslOperation = function (id) {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getFslOperation, id, function (actual, ev) {
                if (ev.status) {
                    deferred.resolve(actual);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        sfdc.getServicesById = function (ids) {

            var deferred = $q.defer();

            sfdc.activeRequests.active += 1;

            Visualforce.remoting.Manager.invokeAction(RemoteActions.getServicesById, ids, function (services, ev) {
                if (ev.status) {
                    deferred.resolve(services);
                    sfdc.activeRequests.active -= 1;
                } else {
                    sfdc.activeRequests.active -= 1;
                    deferred.reject(ev);
                }
            }, { buffer: false, escape: false, timeout: 120000 });

            return deferred.promise;
        };

        return sfdc;
    }]);
})();