'use strict';

/*

 LoadServiceListService
 Service to aggregate all service list loading functions

 */

(function () {

    LastKnownPositionService.$inject = ['$q', 'sfdcService', 'utils'];

    angular.module('serviceExpert').factory('LastKnownPositionService', LastKnownPositionService);

    function LastKnownPositionService($q, sfdcService, utils) {

        var _lastKnownPositions = {};

        function updatePositions(positions) {
            var updated = {};
            var isUpdated = false;

            for (var resourceId in positions) {
                var lastPos = new LastKnownPosition(positions[resourceId]);

                if (!_lastKnownPositions[lastPos.id] || _lastKnownPositions[lastPos.id].lastModifiedDate < lastPos.lastModifiedDate) {
                    updated[resourceId] = lastPos;
                    _lastKnownPositions[resourceId] = lastPos;
                    isUpdated = true;
                }
            }

            return {
                dic: updated,
                isUpdated: isUpdated
            };
        }

        function getLastKnownPositions() {
            return sfdcService.getLivePositions().then(function (positions) {

                for (var resourceId in positions) {
                    _lastKnownPositions[resourceId] = new LastKnownPosition(positions[resourceId]);
                }

                return _lastKnownPositions;
            });
        }

        return {
            getLastKnownPositions: getLastKnownPositions,
            updatePositions: updatePositions,
            lastKnownPositions: function lastKnownPositions() {
                return _lastKnownPositions;
            }
        };
    }
})();