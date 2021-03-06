/*jshint globalstrict: true*/

var STK = STK || {
};

STK.accessibility = {
    textResizing: function () {
        $('.accessibility.text-resizing-guidance span').hover(function () {
            $(this).next('p').toggle();
        });
    }
};

STK.navigation = {
    mobileMenu: function (tree) {
        // adds branch buttons for expanding/contracting submenu
        tree.find('li.parent').each(function () {
            var branchButton = $(document.createElement('a')).addClass('branch-button').attr('href', '#');
            $(this).prepend(branchButton);
        });
        // bind branch button click event
        tree.find('.branch-button').on('click', function (e) {
            $(this).nextAll('ul').each(function () {
                if ($(this).is(':visible')) {
                    $(this).parent().addClass('contracted').removeClass('expanded');
                } else {
                    $(this).parent().addClass('expanded').removeClass('contracted');
                }
                $(this).slideToggle();
            });
            e.preventDefault();
        });
    },
    toggleMenu: function (menu, trigger, options) {
        var defaults = {
            speed: 100
        };
        var settings = $.extend({
        },
        defaults, options);
        trigger.click(function (e) {
            e.stopPropagation();
            if (menu.is(':hidden')) {
                menu.slideDown(settings.speed);
                trigger.removeClass('contracted').addClass('expanded');
            } else {
                menu.slideUp(settings.speed);
                trigger.removeClass('expanded').addClass('contracted');
            }
        });
        menu.parent().click(function (e) {
            e.stopPropagation();
        });
    }
};

/*STK.pagination = {
// add ajax (click triggered) pagination to a content list
clickLoad: function (list, callback) {
var indexCounter = 0;
var count = parseInt(list.data('count'));
var totalCount = parseInt(list.data('totalcount'));
var windowUrl = list.data('windowurl');
var showMoreText = (list.data('show-more-text') || 'Show #count more').replace('#count', count);
var showingText = function() {
return (list.data('showing-text') || 'Showing #count of #totalcount').replace('#totalcount', totalCount).replace('#count', count + indexCounter);
}

if (count && totalCount && windowUrl && count < totalCount) {
var wait = false;
var trigger = $('<div/>').addClass('pagination click-load');
trigger.append($('<div/>').addClass('show-more').text(showMoreText));
trigger.append($('<div/>').addClass('showing').text(showingText()));
trigger.insertAfter(list);
trigger.click(function () {
if (!wait) {
trigger.addClass('loading');
wait = true;
$.ajax({
url: windowUrl.replace('REPLACEWITHINDEX', indexCounter += count),
success: function(data) {
var showingCount = Math.min(indexCounter + count, totalCount);
if (showingCount === totalCount) {
trigger.hide();
}
trigger.find('.showing').text(showingText());
var listElements = $(document.createElement('div')).append(data).find(list.selector + ' > li');
list.append(listElements);
},
error: function() {
indexCounter -= count;
},
complete: function() {
if (typeof(callback) == 'function') {
callback();
}
}
}).always( function() {
trigger.removeClass('loading');
wait = false;
});
}
});
}
}
};*/


STK.pagination = {
    // add ajax (click triggered) pagination to a content list
    clickLoad: function (list, pagination, callback) {
        if (list.length && pagination.length) {
            var indexCounter = 0;
            var count = parseInt(pagination.data('count'), 10);
            var totalCount = parseInt(pagination.data('totalcount'), 10);
            var windowUrl = pagination.data('windowurl');
            var showMoreText = (pagination.data('show-more-text') || 'Show #count more').replace('#count', count);
            var showingText = function () {
                return (pagination.data('showing-text') || 'Showing #count of #totalcount').replace('#totalcount', totalCount).replace('#count', count + indexCounter);
            };
            
            console.log(count);
            
            if (! isNaN(count) && ! isNaN(totalCount) && windowUrl && count < totalCount) {
                var wait = false;
                pagination.addClass('click-load');
                pagination.find('ul').addClass('audible');
                var trigger = $('<div/>').addClass('pagination ajax');
                trigger.append($('<div/>').addClass('show-more').text(showMoreText));
                trigger.append($('<div/>').addClass('showing').text(showingText()));
                trigger.appendTo(pagination);
                trigger.click(function () {
                    if (! wait) {
                        trigger.addClass('loading');
                        wait = true;
                        $.ajax({
                            url: windowUrl.replace('REPLACEWITHINDEX', indexCounter += count),
                            success: function (data) {
                                var showingCount = Math.min(indexCounter + count, totalCount);
                                if (showingCount === totalCount) {
                                    trigger.hide();
                                }
                                trigger.find('.showing').text(showingText());
                                var listElements = $(document.createElement('div')).append(data).find(list.selector + ' > li');
                                list.append(listElements);
                            },
                            error: function () {
                                indexCounter -= count;
                            },
                            complete: function () {
                                if (typeof (callback) === 'function') {
                                    callback();
                                }
                            }
                        }).always(function () {
                            trigger.removeClass('loading');
                            wait = false;
                        });
                    }
                });
            }
        }
    }
};


STK.responsive = {
    optimizeImages: function () {
        $('img[data-srcset]').each(function () {
            var img = $(this);
            var srcset = img.data('srcset');
            if (typeof srcset === 'object') {
                var sizes =[];
                $.each(srcset, function (index) {
                    sizes.push(parseInt(index, 10));
                });
                sizes.sort(function (a, b) {
                    return a - b;
                });
                var width = Math.floor(img.width() * (window.devicePixelRatio || 1));
                var srcIndex = getClosestHigherNum(width, sizes);
                img.attr('src', srcset[srcIndex]);
            }
        });
    },
    
    
    optimizeIframes: function (selectors) {
        selectors.each(function () {
            var iframe = $(this);
            var ratio = (iframe.height() / iframe.width()) * 100;
            var wrapper = $('<div/>').addClass('iframe-wrapper').css('padding-top', ratio + '%');
            iframe.wrap(wrapper);
        });
    }
};




// Get's the closest higher number in array
function getClosestHigherNum(num, ar) {
    var closest = ar[ar.length - 1];
    for (var i = ar.length; i > 0; i--) {
        if (ar[i] > num) {
            closest = ar[i];
        }
    }
    return closest;
}