'use strict';

(function () {
    angular.module('serviceExpert').factory('ResourceCapacitiesService', ['ResourcesAndTerritoriesService', 'TimePhasedDataService', '$rootScope', 'utils', 'StateService', function (ResourcesAndTerritoriesService, TimePhasedDataService, $rootScope, utils, StateService) {

        var cachedContractorDates = {};

        $rootScope.$on('gotNewTimePhasedObjects', function (ev, timePhasedObjects) {
            if (StateService.areContractorsSupported()) drawContractorsTimeSpans(timePhasedObjects.start, timePhasedObjects.finish);
        });

        function drawContractorsTimeSpans(start, finish) {
            var currDay = new Date(start);
            var sectionIds = null;

            while (currDay < finish) {
                var formatedDate = utils.formatDayToString(currDay);

                if (!cachedContractorDates[formatedDate]) {
                    cachedContractorDates[formatedDate] = true;
                    if (!sectionIds) sectionIds = buildSectionIdsArray();

                    var currFinish = new Date(currDay);
                    currFinish.setDate(currFinish.getDate() + 1);

                    for (var i = 0; i <= sectionIds.length; i++) {
                        addMarkedTimeSpan(new Date(currDay), new Date(currFinish), sectionIds[i]);
                    }
                }

                currDay.setDate(currDay.getDate() + 1);
            }
        }

        function addMarkedTimeSpan(start, finish, sectionId) {
            if (start.getTime() == finish.getTime()) return;

            var sectionsToDraw = {};
            for (var key in scheduler.matrix) {

                // don't draw calendars on monthly view
                if (key === 'MonthlyView') {
                    continue;
                }

                sectionsToDraw[key] = [sectionId];
            }

            var cssClass = 'capacityPattern';

            scheduler.addMarkedTimespan({
                start_date: start,
                end_date: finish,
                sections: sectionsToDraw,
                css: cssClass
            });
        }

        function buildSectionIdsArray() {
            var sectionIds = [];
            var resourcesToTimePhasedLocations = TimePhasedDataService.resourcesAndTerritories();

            for (var i = 0; i <= ResourcesAndTerritoriesService.contractorResources.length; i++) {
                var contractorResourceId = ResourcesAndTerritoriesService.contractorResources[i];

                //get timephased territories of contractor resource
                var timePhasedTerritories = resourcesToTimePhasedLocations[contractorResourceId];

                for (var timePhasedTerId in timePhasedTerritories) {
                    var timePhasedLoc = timePhasedTerritories[timePhasedTerId];
                    sectionIds.push(utils.generateResourceId(contractorResourceId, timePhasedLoc.serviceTerritory));
                }
            }

            return sectionIds;
        }

        return {};
    }]);
})();