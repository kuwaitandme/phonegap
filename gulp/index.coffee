gulp   = require 'gulp'
config = require './config'

module.exports = (tasks) ->
	for taskname in tasks

		# Get the task
		taskRegister = require "./tasks/#{taskname}"

		# Get the config for the task
		taskConfig = config[taskname] or {}

		# Register each generated task with the taskname
		taskRegister gulp, taskConfig

	gulp