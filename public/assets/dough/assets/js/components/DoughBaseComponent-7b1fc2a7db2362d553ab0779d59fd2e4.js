define([],function(){"use strict";function t(t,n,e){if(!t||!t.length)throw new Error("Element not supplied to DoughBaseComponent constructor");return this.config=$.extend({},e||{},n||{}),this.componentName=this.config.componentName,this.setElement(t),this.attrs=[],this._bindUiEvents(this.config.uiEvents||{}),this}t.extend=function(n,e){function i(){}var o=e||t;i.prototype=o.prototype,n.prototype=new i,n.prototype.constructor=n,n.baseConstructor=o,n.superclass=o.prototype};var n=t.prototype;return n.setElement=function(t){return this.$el=t,this},n.destroy=function(){return this._unbindUiEvents(),this},n._bindUiEvents=function(t){var n=/^(\S+)\s*(.*)$/;if(!t)return this;this._unbindUiEvents();for(var e in t){var i=this[t[e]];if(i){var o=e.match(n),s=o[1],r=o[2];i=$.proxy(i,this),s+="."+this.componentName+"-boundUiEvents",""===r?this.$el.on(s,i):this.$el.on(s,r,i)}}return this},n._unbindUiEvents=function(){return this.$el.off("."+this.componentName+"-boundUiEvents"),this},n._initialisedSuccess=function(t){this.$el.attr("data-dough-"+this.componentName+"-initialised","yes"),t&&t.resolve(this.componentName)},n._initialisedFailure=function(t){t&&t.reject(this.componentName)},t});