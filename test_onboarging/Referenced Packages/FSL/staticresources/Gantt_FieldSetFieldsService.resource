'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

/*

 FieldSetFieldsService
 Bring it.

 */

(function () {

    FieldSetFieldsService.$inject = ['$q', 'sfdcService'];

    angular.module('serviceExpert').factory('FieldSetFieldsService', FieldSetFieldsService);

    function FieldSetFieldsService($q, sfdcService) {

        // hold promises
        var deferred = $q.defer(),
            fieldsSetFieldsObject = {};

        $q.all([sfdcService.getServiceListFields(), sfdcService.getServiceMiniFormFields(), sfdcService.getServiceMapInfoWindowFields(), sfdcService.getGanttToolTipFields(), sfdcService.getServiceCapacityColumns()]).then(function (fieldsListArray) {

            fieldsSetFieldsObject = {
                ListColumns: fieldsListArray[0],
                ListExpanded: fieldsListArray[1],
                MapInfo: fieldsListArray[2],
                GanttToolTip: fieldsListArray[3],
                CapacityServiceColumns: fieldsListArray[4]
            };

            // if we inject this to another controller, don't overwrite prototype
            if (_typeof(GanttService.prototype.allFieldSets) !== 'object') GanttService.prototype.allFieldSets = fieldsSetFieldsObject;

            deferred.resolve(fieldsSetFieldsObject);
        }).catch(function (ex) {
            deferred.reject();
            console.warn('FieldSetFieldsService: unable to get service appointment field sets');
        });

        // This will be our resource factory
        return {
            fieldsSetFields: function fieldsSetFields() {
                return deferred.promise;
            }
        };
    }
})();