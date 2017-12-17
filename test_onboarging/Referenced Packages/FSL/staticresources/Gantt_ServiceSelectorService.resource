'use strict';

/*

 ServiceSelectorService
 Service for selecting service appointments in the service list

 */

(function () {

    ServiceSelectorService.$inject = ['$filter', 'servicesService', 'TimePhasedDataService', 'sfdcService', 'DeltaService'];

    angular.module('serviceExpert').factory('ServiceSelectorService', ServiceSelectorService);

    function ServiceSelectorService($filter, servicesService, TimePhasedDataService, sfdcService, DeltaService) {

        var SelectedServices = {},
            filter = servicesService.filter,
            serviceListFields = [],
            filteredValue = {};

        DeltaService.register('services', function (services) {
            if (services.deleted) {
                services.deleted.forEach(function (id) {
                    return delete SelectedServices[id];
                });
            }
        });

        sfdcService.getServiceListFields().then(function (res) {
            serviceListFields = res;
        });

        function unselectAll() {
            for (var key in SelectedServices) {
                SelectedServices[key] = false;
            }
        }

        function selectAll() {
            filteredValue = $filter('servicesListFilter')(TimePhasedDataService.serviceAppointments(), filter, serviceListFields);
            for (var i = 0; i < filteredValue.length; i++) {
                SelectedServices[filteredValue[i].id] = true;
            }
        }

        function selectViolations() {
            unselectAll();
            var filterCopy = angular.copy(filter);
            filterCopy.selectedFilter = 'Violating';
            if (filter.selectedFilter == 'Custom filter') {
                filterCopy.endDate = filter.advancedFilter.maxDate;
            }

            filteredValue = $filter('servicesListFilter')(TimePhasedDataService.serviceAppointments(), filter, serviceListFields);
            filteredValue = $filter('servicesListFilter')(filteredValue, filterCopy, serviceListFields);
            for (var i = 0; i < filteredValue.length; i++) {
                SelectedServices[filteredValue[i].id] = true;
            }
        }

        function selectInJeopardy() {
            unselectAll();
            var filterCopy = angular.copy(filter);
            filterCopy.selectedFilter = 'inJeopardy';
            if (filter.selectedFilter == 'Custom filter') {
                filterCopy.endDate = filter.advancedFilter.maxDate;
            }

            filteredValue = $filter('servicesListFilter')(TimePhasedDataService.serviceAppointments(), filter, serviceListFields);
            filteredValue = $filter('servicesListFilter')(filteredValue, filterCopy, serviceListFields);
            for (var i = 0; i < filteredValue.length; i++) {
                SelectedServices[filteredValue[i].id] = true;
            }
        }

        function selectUnscheduled() {
            unselectAll();
            var filterCopy = angular.copy(filter);
            filterCopy.selectedFilter = 'Unscheduled';
            if (filter.selectedFilter == 'Custom filter') {
                filterCopy.endDate = filter.advancedFilter.maxDate;
            }

            filteredValue = $filter('servicesListFilter')(TimePhasedDataService.serviceAppointments(), filter, serviceListFields);
            filteredValue = $filter('servicesListFilter')(filteredValue, filterCopy, serviceListFields);
            for (var i = 0; i < filteredValue.length; i++) {
                SelectedServices[filteredValue[i].id] = true;
            }
        }

        function countSelectedServices() {

            var count = 0;

            for (var key in SelectedServices) {
                if (SelectedServices[key]) count++;
            }return count;
        }

        function getSelected() {

            var selectedArray = [];

            for (var id in SelectedServices) {
                SelectedServices[id] && selectedArray.push(id);
            }

            return selectedArray;
        }

        return {
            SelectedServices: SelectedServices,
            unselectAll: unselectAll,
            selectAll: selectAll,
            selectViolations: selectViolations,
            selectInJeopardy: selectInJeopardy,
            selectUnscheduled: selectUnscheduled,
            countSelectedServices: countSelectedServices,
            getSelected: getSelected
        };
    }
})();