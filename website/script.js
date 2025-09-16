document.addEventListener('DOMContentLoaded', function(){
    // Navigation functionality
    const navDots = document.querySelectorAll('.nav-dot');
    const sections = document.querySelectorAll('section');
    let activeSection = 'about';

    navDots.forEach(dot => {
        dot.addEventListener('click', () => {
            const sectionId = dot.getAttribute('data-section');
            document.getElementById(sectionId).scrollIntoView({ behavior: 'smooth' });
        });
    });

    // Update active navigation dot
    function updateActiveNav(sectionId) {
        navDots.forEach(dot => {
            const isActive = dot.getAttribute('data-section') === sectionId;
            if (isActive) {
                dot.classList.add('is-active');
            } else {
                dot.classList.remove('is-active');
            }
        });
    }

    // Intersection Observer for section animations and navigation
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-fade-in-up');
                activeSection = entry.target.id;
                updateActiveNav(activeSection);
            }
        });
    }, { 
        threshold: 0.3, 
        rootMargin: '0px 0px -20% 0px' 
    });

    sections.forEach(section => {
        observer.observe(section);
    });

    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Theme toggle switch
    let darkmode = localStorage.getItem('darkmode')
    const themeSwitch = document.getElementById('theme-toggle')

    const enableDarkMode = () => {
        document.body.classList.add('darkmode')
        localStorage.setItem('darkmode', 'active')
    }

    const disableDarkMode = () => {
        document.body.classList.remove('darkmode')
        localStorage.setItem('darkmode', null)
    }

    if(darkmode === "active") enableDarkMode()

    themeSwitch.addEventListener("click", () => {
        darkmode = localStorage.getItem('darkmode')
        darkmode !== "active" ? enableDarkMode() : disableDarkMode()
    })
});