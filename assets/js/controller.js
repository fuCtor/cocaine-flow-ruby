// Controllers 
(function () {
    angular.module("cocaine.controllers", [])
        .controller("AppsCtrl", function ($scope, $location, api, sse) {
            $scope.current_status = {}
            $scope.apps = []
            api.apps.list().success(function (data) {
                var exists_app = []
                $scope.apps = $scope.apps.filter(function (app) {
                    ex = data.indexOf(app.name) !== -1;
                    if (ex) {
                        exists_app.push(app.name);
                    }
                    return ex;
                })
                for (i = 0; i < data.length; i++) {
                    if (exists_app.indexOf(data[i]) == -1) {
                        $scope.apps.push({name: data[i]});
                    }
                }
            })

            $scope.start = function (app) {
                api.apps.start(app.name)
            }
            $scope.stop = function (app) {
                api.apps.stop(app.name)
            }
            $scope.restart = function (app) {
                api.apps.restart(app.name)
            }

            $scope.showDetail = function (app) {
                $scope.current_app = app;
                api.apps.status(app.name).success(function(data) {
                    app.status = data
                }).error(function() {
                    app.status = {state: 'stopped' }
                });
            }

            $scope.$root.$on('sse.message', function(e, data){
                for(i = 0; i < $scope.apps.length; i++)
                {
                    if($scope.apps[i].name == data.id)
                    {
                        $scope.apps[i].status = data;
                        $scope.$apply();
                        return;
                    }
                }
                $scope.apps.push({name: data.id, status: data });
            })

        })
        .controller("AppCtrl", function ($scope, $location) {
        })

})();
