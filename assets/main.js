let ogHeight
const navs = $('.navs')
function expandNavigation() {
    if(navs.width() == 0){
        $('.navs').css('width', '100vw');
        
        console.log('open')
    }
}

function closeNavigation() {
    $('.navs').css('width', '0px');

}

let isResizing = false;
$(window).on('resize', function() {
    isResizing = true
    if ($(window).width() >= 625) {
        navs.css('width', 'max-content');
    } 
    else {
        navs.css('width', '0px');
    }
});

function toggleHeight() {
    const parent = document.querySelector('.collapsible');
    const ogPadding = $(parent).css('padding')
    if(parent.clientHeight != 0){
        ogHeight = parent.clientHeight
        parent.style.height = "0px"
        parent.style.paddingBottom = "0px"
        parent.style.paddingTop = "0px"
    }
    else{
        parent.style.height = ogHeight + "px"
        parent.style.paddingTop = "24px"
        parent.style.paddingBottom = "24px"
        
    }
  }