function calculateTierAmount() {
    const tier = parseInt(document.querySelector('input[name="tier"]:checked').value, 10) || 0;
    const studentCount = parseInt(document.getElementById('student_count').value, 10) || 0;
    document.getElementById('amount').value = tier * studentCount;
}

document.addEventListener("DOMContentLoaded", function () {
    console.log("Payment form script loaded");

    // Step navigation listeners
    document.getElementById('next-to-2').addEventListener('click', function () {
        validateAndGoToStep(1, 2);
    });

    document.getElementById('prev-to-1').addEventListener('click', function () {
        goToStep(1);
    });

    document.getElementById('next-to-3').addEventListener('click', function () {
        validateAndGoToStep(2, 3);
    });

    document.getElementById('prev-to-2').addEventListener('click', function () {
        goToStep(2);
    });

    document.getElementById('next-to-4').addEventListener('click', function () {
        validateAndGoToStep(3, 4);
    });

    document.getElementById('prev-to-3').addEventListener('click', function () {
        goToStep(3);
    });

    // Initialize Stripe on step 3 and variables for tracking progress
    let stripe = null;
    let card = null;
    let cardComplete = false;
    let last4 = null;

    function validateAndGoToStep(currentStep, nextStep) {
        if (validateStep(currentStep)) {
            if (nextStep === 4) {
                updateReviewInformation();
            }
            goToStep(nextStep);
        }
    }


    function goToStep(stepNumber) {
        // Hide all steps first
        document.querySelectorAll('#payment-form-wizard > div').forEach(step => {
            step.classList.add('hidden');
        });

        // Show only the current step
        document.getElementById(`step-${stepNumber}`).classList.remove('hidden');

        // Update progress bar indicators
        updateProgressBar(stepNumber);

        // Initialize Stripe if going to step 3
        if (stepNumber === 3) {
            initializeStripe();
        }
    }

    function updateProgressBar(stepNumber) {
        // Reset all step indicators
        const stepIndicators = document.querySelectorAll('#payment-wizard-container .flex-1 > div:first-child');
        stepIndicators.forEach((indicator, index) => {
            if (index + 1 < stepNumber) {
                indicator.classList.remove('bg-gray-200', 'text-gray-600', 'bg-blue-500', 'text-white');
                indicator.classList.add('bg-green-500', 'text-white', 'border-green-500');
            } else if (index + 1 === stepNumber) {
                indicator.classList.remove('bg-gray-200', 'text-gray-600', 'bg-green-500');
                indicator.classList.add('bg-blue-500', 'text-white', 'border-blue-500');
            } else {
                indicator.classList.remove('bg-blue-500', 'text-white', 'bg-green-500', 'border-green-500', 'border-blue-500');
                indicator.classList.add('bg-gray-200', 'text-gray-600', 'border-gray-200');
            }
        });
    }


    function validateStep(step) {
        switch (step) {
            case 1: {
                const firstName = document.getElementById('first_name').value;
                const lastName = document.getElementById('last_name').value;
                const email = document.getElementById('email').value;
                const schoolName = document.getElementById('school_name').value;
                const schoolAddress = document.getElementById('school_address').value;

                if (!firstName || !lastName || !email || !schoolName || !schoolAddress) {
                    alert('Please fill in all required fields');
                    return false;
                }

                const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                if (!emailRegex.test(email)) {
                    alert('Please enter a valid email address');
                    return false;
                }

                return true;
            }
            case 2: {
                const amount = document.getElementById('amount').value;
                if (!amount || amount <= 0) {
                    alert('Please enter a valid amount');
                    return false;
                }
                return true;
            }
            case 3: {
                if (!cardComplete) {
                    alert('Please complete the card information');
                    return false;
                }
                return true;
            }
            default:
                return true;
        }
    }

    function initializeStripe() {
        const cardElement = document.getElementById('card-element');
        if (!cardElement) return;

        if (!stripe) {
            stripe = Stripe(publishableKey);
        }

        if (card) {
            card.destroy();
        }

        const elements = stripe.elements();
        card = elements.create("card");
        card.mount("#card-element");

        card.addEventListener('change', (event) => {
            const displayError = document.getElementById('card-errors');
            if (event.error) {
                displayError.textContent = event.error.message;
                cardComplete = false;
            } else {
                displayError.textContent = '';
                cardComplete = event.complete;
                if (event.complete && event.value?.card?.last4) {
                    last4 = event.value.card.last4;
                    console.log(last4);
                }
            }
        });
    }

    function updateReviewInformation() {
        const firstName = document.getElementById('first_name').value;
        const lastName = document.getElementById('last_name').value;
        const amount = document.getElementById('amount').value;
        const email = document.getElementById('email').value;
        const schoolName = document.getElementById('school_name').value;
        const schoolAddress = document.getElementById('school_address').value;
        let tier = document.querySelector('input[name="tier"]:checked').value;

        if (tier === "200") {
            tier = "Basic";
        } else {
            tier = "Premium";
        }


        document.getElementById('review-name').textContent = `${firstName} ${lastName}`;
        document.getElementById('review-amount').textContent = amount
        document.getElementById('review-email').textContent = email;
        document.getElementById('review-school-name').textContent = schoolName;
        document.getElementById('review-school-address').textContent = schoolAddress;
        document.getElementById('review-tier').textContent = tier;

        if (last4) {
            document.getElementById('review-card-last4').textContent = "****" + last4;
        }
    }


    // Handle payment form submission
    document.getElementById('submit-payment').addEventListener('click', async function () {
        const firstName = document.getElementById('first_name').value;
        const lastName = document.getElementById('last_name').value;
        const amount = document.getElementById('amount').value;
        const email = document.getElementById('email').value;
        const schoolName = document.getElementById('school_name').value;
        const schoolAddress = document.getElementById('school_address').value;
        const tier = document.querySelector('input[name="tier"]:checked').value;

        const submitButton = document.getElementById('submit-payment');
        submitButton.disabled = true;
        submitButton.textContent = 'Processing...';

        const endpoint = isRenewal ? '/payments/renew_payment' : '/payments';
        try {
            const {paymentMethod, error} = await stripe.createPaymentMethod({
                type: "card",
                card: card,
                billing_details: {
                    name: `${firstName} ${lastName}`,

                }
            });

            if (error) {
                alert(error.message);
                submitButton.disabled = false;
                submitButton.textContent = 'Complete Payment';
                return;
            }

            const response = await fetch(endpoint, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": csrfToken
                },
                body: JSON.stringify({
                    first_name: firstName,
                    last_name: lastName,
                    amount: parseInt(amount),
                    payment_method_id: paymentMethod.id,
                    email: email,
                    schoolAddress: schoolAddress,
                    school_name: schoolName,
                    tier: tier,
                    renew: isRenewal
                }),
            });

            if (response.ok) {
                window.location.href = "/payments/success";
            } else {
                alert("Payment failed!");
                submitButton.disabled = false;
                submitButton.textContent = 'Complete Payment';
            }
        } catch (e) {
            alert("An unexpected error occurred: " + e.message);
            submitButton.disabled = false;
            submitButton.textContent = 'Complete Payment';
        }
    });
});
