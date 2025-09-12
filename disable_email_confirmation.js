// Script to disable email confirmation in Supabase
// Run this in your browser console on the Supabase dashboard

// Method 1: Try to find and click the toggle
function findAndDisableEmailConfirmation() {
    // Look for common toggle elements
    const toggles = document.querySelectorAll('input[type="checkbox"], button[role="switch"], .toggle, .switch');
    
    toggles.forEach(toggle => {
        const label = toggle.closest('label') || toggle.parentElement;
        if (label && label.textContent.toLowerCase().includes('email') && 
            (label.textContent.toLowerCase().includes('confirm') || 
             label.textContent.toLowerCase().includes('verification'))) {
            console.log('Found email confirmation toggle:', label.textContent);
            if (toggle.checked || toggle.getAttribute('aria-checked') === 'true') {
                toggle.click();
                console.log('Toggled OFF email confirmation');
            }
        }
    });
}

// Method 2: Look for specific text patterns
function searchForEmailSettings() {
    const elements = document.querySelectorAll('*');
    const emailSettings = [];
    
    elements.forEach(el => {
        if (el.textContent && 
            (el.textContent.includes('email confirm') || 
             el.textContent.includes('email verification') ||
             el.textContent.includes('confirm signup'))) {
            emailSettings.push({
                element: el,
                text: el.textContent.trim()
            });
        }
    });
    
    console.log('Found email-related elements:', emailSettings);
    return emailSettings;
}

// Run the search
console.log('Searching for email confirmation settings...');
searchForEmailSettings();
findAndDisableEmailConfirmation();

// Instructions for manual search
console.log(`
Manual Instructions:
1. Look for text containing "email confirm" or "email verification"
2. Look for toggle switches or checkboxes
3. Look for sections titled "Email Settings" or "Auth Settings"
4. Check if there's a "Settings" tab in the current page
5. Look for a "Save" or "Update" button after making changes
`);
