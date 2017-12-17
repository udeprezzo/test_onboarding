'use strict';

(function () {

    angular.module('serviceExpert').filter('timelineFilter', timelineFilter);

    timelineFilter.$inject = ['utils', 'ResourcesAndTerritoriesService', 'TimePhasedDataService', 'SkillsService', 'calendarsService', 'userSettingsManager', 'GetSlotsService', 'StateService', 'resourceFilterHelper', 'LastKnownPositionService', 'monthlyViewHelperService', 'DeltaService'];

    function timelineFilter(utils, ResourcesAndTerritoriesService, TimePhasedDataService, SkillsService, calendarsService, userSettingsManager, GetSlotsService, StateService, resourceFilterHelper, LastKnownPositionService, monthlyViewHelperService, DeltaService) {

        var nowUtc = new Date().getTime();

        setInterval(function () {
            return nowUtc += 60000;
        }, 60000);

        // register for updated positions and update the resource object
        DeltaService.register('positions', function (updatedPositions) {

            var resources = ResourcesAndTerritoriesService.getResources();

            for (var resourceId in updatedPositions) {

                if (!resources[resourceId]) {
                    continue;
                }

                resources[resourceId].lastKnownLongitude = updatedPositions[resourceId].longitude;
                resources[resourceId].lastKnownLocationDate = updatedPositions[resourceId].lastModifiedDate.getTime() - updatedPositions[resourceId].lastModifiedDate.getTimezoneOffset() * 1000 * 60;
                resources[resourceId].lastKnownLatitude = updatedPositions[resourceId].latitude;
            }
        });

        return function (resources, filterText, skillsFilter, selectedSkills, resourceFilterOptions, resourceFieldsetOptions) {

            var timelineData = [],
                rowsIndexToIds = {},
                selectedSkillsArray = [],
                searchResourceNameArray = filterText.replace(/, /g, ',').split(','),
                resourcesAndTerritories = TimePhasedDataService.resourcesAndTerritories(),
                territoriesArray = Object.keys(ResourcesAndTerritoriesService.territories).map(function (key) {
                return ResourcesAndTerritoriesService.territories[key];
            }).sort(sortByName);

            // create territories objects
            territoriesArray.forEach(function (territory) {
                timelineData.push(new Territory(territory, ResourcesAndTerritoriesService.operatingHours[territory.operatingHours], StateService));
                rowsIndexToIds[territory.id] = timelineData.length - 1;
            });

            // if we have skills filter defined, create an arry with all the selected keys
            if (skillsFilter) {
                for (var skillId in selectedSkills) {
                    selectedSkills[skillId] && selectedSkillsArray.push(skillId);
                }
            }

            var loadedLocations = userSettingsManager.GetUserSettingsProperty('locations');

            // go over all resources that have a timephase
            for (var resourceId in resourcesAndTerritories) {

                var obj = resourcesAndTerritories[resourceId],
                    resource = ResourcesAndTerritoriesService.getResources()[resourceId];

                // check that resource exist - might have no permissions
                if (!resource) {
                    continue;
                }

                // check if resource is filtered by name
                if (!isSearchResourceMatched(resource.name, searchResourceNameArray)) {
                    continue;
                }

                // check if resource DOES NOT have all selected skills skills (including timephase)
                if (skillsFilter && !SkillsService.doesHaveSkills(resourceId, selectedSkillsArray, scheduler._min_date, scheduler._max_date)) {
                    continue;
                }

                var foundMissMatchedSkill = false;

                // fieldset check - booleans
                for (var iField in resourceFieldsetOptions.resourceFilteringOptions) {

                    // does a certian boolean is checked on the filter? if so, check if it's true on the resource
                    if (resourceFieldsetOptions.resourceFilteringOptions[iField]) {
                        if (!resource.sobject[iField]) {
                            foundMissMatchedSkill = true;
                            break;
                        }
                    }
                }

                // a boolean field wasn't found on the resource, we shouldn't include it;
                if (foundMissMatchedSkill) {
                    continue;
                }

                // fieldset check - fieldset
                if (resourceFieldsetOptions.selectedPicklist !== 'select_a_field') {

                    // is the picklist value NOT selected? (at least 1 value should be selected!)
                    if (resourceFieldsetOptions.picklistOptions.length > 0 && resourceFieldsetOptions.picklistOptions.indexOf(resource.sobject[resourceFieldsetOptions.selectedPicklist]) === -1) {

                        // no null values accepted
                        if (!resourceFieldsetOptions.picklistNullValues) {
                            continue;
                        }

                        // null values accepted but the picklist value IS defined
                        else if (typeof resource.sobject[resourceFieldsetOptions.selectedPicklist] !== 'undefined') {
                                continue;
                            }
                    }

                    // only "not defined" is selected
                    if (resourceFieldsetOptions.picklistOptions.length === 0 && resourceFieldsetOptions.picklistNullValues && typeof resource.sobject[resourceFieldsetOptions.selectedPicklist] !== 'undefined') {
                        continue;
                    }
                }

                // if get candidates was invoked, show only resources that are candidates
                if (GetSlotsService.getCandidatesIds() && !GetSlotsService.getCandidatesIds()[resourceId]) {
                    continue;
                }

                // check if timephase intersect
                for (var timephaseId in obj) {
                    // only working resources
                    var sectionId = utils.generateResourceId(obj[timephaseId].serviceResource, obj[timephaseId].serviceTerritory);
                    if (resourceFilterOptions.showWorkingResource && !isResourceWorkingInVisibleGantt(sectionId, calendarsService, utils)) continue;

                    // check if 4 words is in loaded locations (in case of a relocation outside of loaded data)
                    if (loadedLocations && loadedLocations.indexOf(obj[timephaseId].serviceTerritory) == -1) continue;

                    if (isTimephaseIntersect(scheduler._min_date, scheduler._max_date, obj[timephaseId].effectiveStartDate, obj[timephaseId].effectiveEndDate)) {
                        var territoryFolder = timelineData[rowsIndexToIds[obj[timephaseId].serviceTerritory]],
                            territoryResource = new Resource(utils.generateResourceId, ResourcesAndTerritoriesService.getResources()[obj[timephaseId].serviceResource], obj[timephaseId].serviceTerritory, isResourceOnline(ResourcesAndTerritoriesService.getResources()[obj[timephaseId].serviceResource]), isSecondaryStm(obj[timephaseId]));

                        if (territoryFolder.children.map(function (row) {
                            return row.key;
                        }).indexOf(territoryResource.key) === -1) {
                            territoryFolder.children.push(territoryResource);
                        }
                    }
                }
            }

            // remove territories that have no active resources
            var emptyTerritories = [],
                totalRemoved = 0;
            timelineData.forEach(function (value, index) {
                return value.children.length === 0 && emptyTerritories.push(index);
            });
            emptyTerritories.forEach(function (value) {
                return timelineData.splice(value - totalRemoved++, 1);
            });
            timelineData.forEach(function (value) {
                return value.children.sort(sortByField);
            });

            if (utils.hasCustomPermission('Utilization_on_Service_Territory') && showDailyUtilization && scheduler._mode !== 'MonthlyView' && scheduler._mode !== 'MTDView') {
                timelineData.forEach(function (value) {

                    var percent = void 0,
                        daysUtilization = [];

                    for (var currDate = new Date(scheduler._min_date); currDate < scheduler._max_date; currDate.setDate(currDate.getDate() + 1)) {
                        daysUtilization.push(monthlyViewHelperService.calculateLocation(value.children, currDate));
                    }

                    var sum = daysUtilization.reduce(function (totals, current) {
                        totals.break += current.break;
                        totals.capacity += current.capacity;
                        totals.overtime += current.overtime;
                        totals.service += current.service;
                        totals.travel += current.travel;
                        totals.na += current.na;

                        return totals;
                    }, { break: 0, capacity: 0, overtime: 0, service: 0, travel: 0, na: 0 });

                    percent = monthlyViewHelperService.calculateLocationUtilization(sum);

                    value.addUtilizationHtml(percent);
                });
            }

            return timelineData;

            function isResourceOnline(resource) {

                if (!resource.lastKnownLocationDate) {
                    resource.online = false;
                    return false;
                }

                if (resource.lastKnownLocationDate && resource.onlineOffset) {

                    resource.lastSeen = parseInt((nowUtc - resource.lastKnownLocationDate) / 1000 / 60);

                    if (resource.lastKnownLocationDate + resource.onlineOffset * 60 * 1000 > nowUtc) {
                        resource.online = true;
                        return true;
                    }
                }

                resource.online = false;
                return false;
            }

            // sort by field
            function sortByField(a, b) {
                var fieldRes1 = ResourcesAndTerritoriesService.getResources()[a.resourceId].sobject[resourceFilterHelper.resourceFieldToSortyBy],
                    fieldRes2 = ResourcesAndTerritoriesService.getResources()[b.resourceId].sobject[resourceFilterHelper.resourceFieldToSortyBy],
                    descending = resourceFilterHelper.descending ? 1 : -1;

                if (fieldRes1 > fieldRes2) return descending;

                if (fieldRes1 < fieldRes2) return -1 * descending;

                return 0;
            }
        };
    }

    function isResourceWorkingInVisibleGantt(sectionId, calendarsService, utils) {
        var currDate = new Date(scheduler._min_date),
            currResourceDates = calendarsService.resourceToWorkingDates[sectionId];

        if (!currResourceDates) return false;

        while (currDate < scheduler._max_date) {
            var resourceSingleDay = currResourceDates[utils.formatDayToString(currDate)];

            if (resourceSingleDay && (resourceSingleDay.regular > 0 || resourceSingleDay.overtime > 0)) {
                return true;
            }

            currDate.setDate(currDate.getDate() + 1);
        }

        return false;
    }

    // check if name is in array
    function isSearchResourceMatched(name, namesArray) {

        if (namesArray.length === 0) {
            return true;
        }

        for (var i = 0; i < namesArray.length; i++) {
            if (name.toLowerCase().indexOf(namesArray[i].toLowerCase()) > -1) {
                return true;
            }
        }

        return false;
    }

    function isSecondaryStm(stmObj) {
        return stmObj.serviceTerritoryType == 'S';
    }

    // check if timephases intersect
    function isTimephaseIntersect(date1_start, date1_end, date2_start, date2_end) {
        return isIntersect(date1_start, date1_end, date2_start, date2_end);
    }

    // sort by ABC, name field
    function sortByName(a, b) {

        if (a.name > b.name) return 1;

        if (a.name < b.name) return -1;

        return 0;
    }

    // location object for dhtmlx
    function Territory(territory, operatingHours, StateService) {
        this.key = territory.id;
        this.name = territory.name;
        this.children = [];
        this.generateHtml(territory, operatingHours.timezone);

        if (StateService.ganttOpenedTerritories[territory.id] === undefined) {
            StateService.ganttOpenedTerritories[territory.id] = true;
        }

        this.open = StateService.ganttOpenedTerritories[territory.id];
    }

    // generate HTML template for folders
    Territory.prototype.generateHtml = function (territory, tzName) {

        if (territory.parentTerritory) {
            this.label = '<div class=\'truncate ParentName\'>' + territory.parentTerritory.name + '</div><div class=\'truncate LocationName\'>' + territory.name + '</div>';
        } else {
            this.label = '<div class=\'truncate LocationName\'>' + territory.name + '</div>';
        }

        if (scheduler._mode !== 'MonthlyView' && scheduler._mode !== 'MTDView') {
            var gmtNow = new Date(),
                marginTop = territory.parentTerritory ? 'margin-top:-26px;' : '';

            gmtNow = new Date(gmtNow.valueOf() + gmtNow.getTimezoneOffset() * 60000);
            gmtNow.setMinutes(gmtNow.getMinutes() + utils.getLocationOffset(gmtNow, territory.id));

            this.label += '<div class=\'timeZoneFolder\' style="' + marginTop + '">' + tzName + ' - ' + moment(gmtNow).format('llll') + '</div>';
        }
    };

    Territory.prototype.addUtilizationHtml = function (percent) {

        var addParentStyle = this.label.indexOf('Parent') > -1 ? 'style="margin-top: -9px"' : '',
            whereToInsert = this.label.indexOf('</div>'),
            percentClassColor = 'green-daily-utlz';

        if (percent >= monthlyViewSettings.high && percent < monthlyViewSettings.critical) {
            percentClassColor = 'yellow-daily-utlz';
        } else if (percent >= monthlyViewSettings.critical) {
            percentClassColor = 'red-daily-utlz';
        }

        // if no territory members, we get a null, display nothing
        if (percent !== null) {
            var percentHtml = '<b class="' + percentClassColor + '">' + percent + '%</b>';
            percent = '<div class="dailyViewUtilization" ' + addParentStyle + '>' + customLabels.UtilizationDaily.replace('$0', percentHtml) + ' </div>';
            this.label = this.label.slice(0, whereToInsert + 6) + percent + this.label.slice(whereToInsert + 6);
        }
    };

    // resource object for dhtmlx
    function Resource(generateIdFunction, resourceObject, territoryId, online, secondary) {
        this.key = generateIdFunction(resourceObject.id, territoryId);
        this.resourceId = resourceObject.id;
        this.name = resourceObject.name;
        this.contractor = false;
        this.online = online;
        this.lastSeen = resourceObject.lastSeen;
        this.secondary = secondary;
        this.generateHtml(resourceObject);
    }

    // generate HTML template for resources
    Resource.prototype.generateHtml = function (resourceObject) {

        this.label = '';

        var onlineClass = this.online ? 'online-indicator' : 'online-indicator offline-indicator';

        var secondaryText = this.secondary ? '<span class=\'secondaryGanttLabel\' title="' + customLabels.Secondary + '">(' + customLabels.Secondary + ')</span>' : '';

        var onlineHtml = !!resourceObject.lastKnownLocationDate && this.lastSeen < 60 * 24 ? '<div class="' + onlineClass + '" title="' + utils.hoursMinutes(this.lastSeen, customLabels.SeenXMinsHoursAgo, customLabels.SeenXAgoHours, customLabels.SeenXAgo) + '"></div>' : '';

        if (resourceObject.pictureLink) {
            var resourcePhotoClass = scheduler.matrix.ZoomLevel3.dy < 33 ? 'SmallResourcePhoto' : 'ResourcePhoto';
            this.label += '<img src=\'' + resourceObject.pictureLink + '\' title=\'' + resourceObject.description + '\' class=\'' + resourcePhotoClass + '\' />' + onlineHtml;
        } else {
            var resourcePhotoDefault = scheduler.matrix.ZoomLevel3.dy < 33 ? 'SmallResourcePhotoDefault' : 'NormalResourcePhotoDefault';
            this.label += '<div title=\'' + resourceObject.description + '\' class="ResourcePhotoIcon ' + resourcePhotoDefault + '"></div>' + onlineHtml;
        }

        // add resource menu button (no need to change size according to row height)
        this.label += '<div class="resourceMenuBtn">\n                            <svg aria-hidden="true" class="slds-icon resourceMenuIcon">\n                                <use xlink:href="' + lsdIcons.threedots + '"></use>\n                            </svg>\n                        </div>';

        if (resourceObject.ganttLabel) {
            if (scheduler.matrix.ZoomLevel3.dy < 33) {
                this.label += '<a resource=\'' + this.id + '\' title=\'' + resourceObject.description + '\'>' + this.name + ' ' + secondaryText + '</a>\n                <div class=\'smallResourceGanttLabel truncate\'>' + resourceObject.ganttLabel + '</div>';
            } else {
                this.label += '<a resource=\'' + this.id + '\' class=\'smallResourceName\' title=\'' + resourceObject.description + '\'>' + this.name + ' ' + secondaryText + '</a>\n                <div class=\'resourceGanttLabel truncate\'>' + resourceObject.ganttLabel + '</div>';
            }
        } else {
            if (scheduler.matrix.ZoomLevel3.dy < 33) {
                this.label += '<a resource=\'' + this.id + '\' class=\'smallResourceName\' style=\'margin-top:6px;\' title=\'' + resourceObject.description + '\'>' + this.name + ' ' + secondaryText + '</a>';
            } else {
                this.label += '<a resource=\'' + this.id + '\' style=\'margin-top:6px;\' title=\'' + resourceObject.description + '\'>' + this.name + ' ' + secondaryText + '</a>';
            }
        }
    };
})();