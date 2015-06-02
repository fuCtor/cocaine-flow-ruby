#= require angular
#= require angular-route

#= require_directory .

"user strict"

deps = ["cocaine.controllers", 'cocaine.services', 'cocaine.directives', "ngRoute"]
app = angular.module("cocaine", deps).config ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    templateUrl: "/__tpl/apps",
    controller: "AppsCtrl"
  $routeProvider.when "/apps/:id",
    templateUrl: "/__tpl/app",
    controller: "AppCtrl"
  $routeProvider.otherwise redirectTo: "/"
  $locationProvider.html5Mode true
