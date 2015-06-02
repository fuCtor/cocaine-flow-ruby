(function () {
    angular.module("cocaine.services", [])
        .factory('api', ['$http', '$timeout', '$log', function ($http, $timeout, $log) {
            var methods = {};
            methods.apps = {
                list: function () {
                    return $http.get('/api/v1/apps')
                },
                status: function (name) {
                    return $http.get('/api/v1/apps/' + name)
                },
                start: function (name) {
                    return $http.post('/api/v1/apps/' + name + '/start')
                },
                stop: function (name) {
                    return $http.post('/api/v1/apps/' + name + '/stop')
                },
                restart: function (name) {
                    return $http.post('/api/v1/apps/' + name + '/restart')
                },
            }
            return methods;
        }])
        .factory('sse', ['$rootScope', function ($rootScope) {
            if (typeof(EventSource) !== "undefined") {
                // Yes! Server-sent events support!
                var source = new EventSource('/events');

                source.onmessage = function (event) {
                    $rootScope.$emit('sse.message', JSON.parse(event.data))
                };
                return source;
            } else {
                console.log('SSE not supported by browser.');
            }
            return {}
        }])
})();
