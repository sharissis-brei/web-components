if("undefined"==typeof quickView){var quickView;this.jQuery&&function(e){quickView={isScrollLocked:!1,isCloseAllowed:!0,initialize:function(){var i=e("body");i.append('<div id="QuickView"><div id="QuickViewCell"></div></div>'),this.$container=e("#QuickView"),this.$containerCell=e("#QuickViewCell"),i.delegate("a","click",function(i){if(i.metaKey)return!0;var n=e(i.currentTarget).attr("href");if(quickView.hasImageExtension(n))return quickView.show('<img src="'+n+'" />'),!1;var t=e(i.currentTarget).attr("data-quickview-content");return t.length?(quickView.show(t),!1):!0})},hasImageExtension:function(e){return e?null!==e.match(/\.(jpeg|jpg|gif|png)$/):void 0},show:function(i,n,t){quickView.$containerCell.html(i).css("height",e(window).height()+"px").css("width",e(window).width()+"px"),quickView.$container.fadeIn(80),quickView.lockScroll(),n||quickView.bindCloseActions(),t&&setTimeout(function(){quickView.addSpecialStyles()},70)},hide:function(){quickView.removeCloseActions(),quickView.$container.fadeOut(40),setTimeout(function(){quickView.$containerCell.empty(),quickView.removeSpecialStyles()},40),quickView.unlockScroll()},addSpecialStyles:function(){var i=e(window).height(),n=quickView.$containerCell.contents().height(),t=Math.round(i/2-n/2),t=Math.max(t,30);0!=n&&quickView.$containerCell.css("paddingTop",t+"px").css("verticalAlign","top")},removeSpecialStyles:function(){quickView.$containerCell.css("paddingTop","").css("verticalAlign","")},bindCloseActions:function(){quickView.$container.on("click",quickView.hide),e("body").on("keyup",quickView.processKeyUp)},removeCloseActions:function(){quickView.$container.off("click",quickView.hide),e("body").off("keyup",quickView.processKeyUp)},processKeyUp:function(e){27===e.which&&quickView.hide()},lockScroll:function(){var e=[self.pageXOffset||document.documentElement.scrollLeft||document.body.scrollLeft,self.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop],i=jQuery("html");i.data("scroll-position",e),i.data("previous-overflow",i.css("overflow")),i.css("overflow","hidden"),window.scrollTo(e[0],e[1]),this.isScrollLocked=!0},unlockScroll:function(){if(!this.isScrollLocked)return!1;var e=jQuery("html"),i=e.data("scroll-position");e.css("overflow",e.data("previous-overflow")),window.scrollTo(i[0],i[1])}},e(document).ready(function(){quickView.initialize()})}(jQuery)}else console.log("Warning: quickView was already defined so we could not load chapmanU/web-components quickView!");!function(e){var i={initialize:function(){e("body").on("click","a",i.trackAction)},trackAction:function(i){var n=e(i.currentTarget).attr("data-analytics-event");if(void 0===n)return!0;var t=n.split(","),o=e(i.currentTarget).attr("href")||!1,c=i.metaKey||i.ctrlKey,a=t[0]||"Call to Action Link",r=t[1]||e(i.currentTarget).html()||"Click",l=t[2]||e(i.currentTarget).attr("href")||void 0,s=parseInt(t[3])||void 0;if("undefined"!=typeof ga)ga("send","event",a,r,l,s);else if("undefined"!=typeof _gaq){if(_gaq.push(["_trackEvent",a,r,l,s]),o&&!c)return setTimeout(function(){window.location.href=o},250),i.preventDefault(),!1}else console.log("Google Analytics is not running, so no Google Analytics tracking data could be sent.")}};e(document).ready(function(){i.initialize()})}(jQuery),this.jQuery&&function(e){var i={show:3,url:"https://inside.chapman.edu/callback/meltwater",initialize:function(n){return i.$container=e("#meltwater"),i.$container.length?(n&&(i.show=n),i.$moreButton=e("<button>Load more...</button>").hide(),i.$moreButton.on("click",i.more),i.$container.append("<ul></ul>"),i.$container.append(i.$moreButton),void i.getData()):!1},getData:function(){e.ajax({url:i.url,success:function(e){i.current=0,i.data=e.feeds.feed.documents.document,i.processData(),console.log("There are "+i.data.length)},error:function(e,n){i.$container.append("<p>Sorry, news items could not be loaded.</p>"),console.log("An error occured fetching Meltwater news stories."),console.log(n)},dataType:"jsonp"})},processData:function(e){for(;this.current<this.show&&this.current<this.data.length;)this.addItem(this.current,e),this.current=this.current+1;this.data.length>this.current?i.$moreButton.show():i.$moreButton.fadeOut()},addItem:function(n,t){var o=i.data[n],c=o.createDate_mon2+"/"+o.createDate_day+"/"+o.createDate_year,a=e('<a href="'+o.url+'"></a>');a.append('<span class="date">'+c+"</span>"),a.append('<span class="title">'+o.title+"</span>"),o.sourcename&&a.append('<span class="sourcename">'+o.sourcename+"</span>"),o.subregion&&a.append('<span class="region">'+o.subregion+"</span>");var r=e("<li></li>").append(a);t>0&&r.hide(function(){r.fadeIn(t)}),i.$container.find("ul").append(r)},more:function(){i.show+=5,i.processData(500)}};e(document).ready(function(){i.initialize()})}(jQuery);