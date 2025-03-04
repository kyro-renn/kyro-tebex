document.addEventListener('DOMContentLoaded', function() {
    const submitCodeButton = document.getElementById('submit-code-button');
    const codeInput = document.getElementById('code-input');
    const closeMenuButton = document.getElementById('close-menu-button');
    const openWebsiteButton = document.getElementById('open-website-button');
    const codeInputMenu = document.getElementById('code-input-menu');
    const notification = document.getElementById('notification');
    const balance = document.getElementById('balance');

    let websiteUrl = '';

    submitCodeButton.addEventListener('click', function() {
        const code = codeInput.value;
        if (code) {
     
            fetch(`https://kyro_tebex/submitCode`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ code: code })
            }).then(response => response.json())
              .then(data => {
                  console.log('Code submitted successfully:', data);
                  notification.textContent = 'Code submitted successfully!';
                  notification.style.display = 'block';
                  updateBalance(data.newBalance); 
              })
              .catch(error => {
                  console.error('Error submitting code:', error);
                  notification.textContent = 'Error submitting code. Please try again.';
                  notification.style.display = 'block';
              });
        } else {
            console.error('Please enter a code.');
            notification.textContent = 'Please enter a code.';
            notification.style.display = 'block';
        }
    });

    closeMenuButton.addEventListener('click', closeMenu);
    openWebsiteButton.addEventListener('click', function() {
        if (websiteUrl) {
            window.invokeNative("openUrl", websiteUrl);

        } else {
            console.error('Website URL is not set.');
        }
    });


    window.addEventListener('message', function(event) {
        if (event.data.action === 'openClaimMenu') {
            codeInputMenu.style.display = 'flex'; 
            updateBalance(event.data.balance); 
            websiteUrl = event.data.site; 
        }
    });

    function closeMenu() {
   
        fetch(`https://kyro_tebex/closeMenu`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(response => response.json())
          .then(data => {
              console.log('Menu closed successfully:', data);
              codeInputMenu.style.display = 'none'; 
              codeInput.value = ''; 
              notification.style.display = 'none'; 
          })
          .catch(error => {
              console.error('Error closing menu:', error);
          });
    }

    function updateBalance(newBalance) {
        balance.textContent = `Balance: $${newBalance}`;
    }
});