document.addEventListener('turbo:load', initializeCategorySelection);
document.addEventListener('DOMContentLoaded', initializeCategorySelection);

function initializeCategorySelection() {
    const container = document.getElementById('categories-container');
    if (!container) return;

    const messages = {
        selectedLabel: container.dataset.selectedLabel || 'Selected:',
        noneSelectedLabel: container.dataset.noneSelectedLabel || 'Click buttons to select movie categories.'
    };

    const labels = container.querySelectorAll('.category-checkbox-label');
    labels.forEach((label) => {
        const newLabel = label.cloneNode(true);
        label.parentNode.replaceChild(newLabel, label);

        const checkbox = newLabel.querySelector('.category-checkbox');
        const button = newLabel.querySelector('.category-button');

        if (!checkbox || !button) return;

        syncButtonState(checkbox, button);

        newLabel.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            checkbox.checked = !checkbox.checked;
            syncButtonState(checkbox, button);
            updateSelectedCategories(messages);
        });
    });

    updateSelectedCategories(messages);
}

function syncButtonState(checkbox, button) {
    if (checkbox.checked) {
        button.classList.add('active');
    } else {
        button.classList.remove('active');
    }
}

function updateSelectedCategories(messages) {
    const container = document.getElementById('categories-container');
    if (!container) return;

    const checkboxes = container.querySelectorAll('.category-checkbox:checked');
    const selectedContainer = document.getElementById('selected-categories');
    const selectedListSpan = document.getElementById('selected-list');

    if (!selectedContainer || !selectedListSpan) return;


    if (checkboxes.length > 0) {
        const names = Array.from(checkboxes).map((cb) => {
            const label = cb.closest('.category-checkbox-label');
            const button = label.querySelector('.category-button');
            return button ? button.textContent.trim() : '';
        }).filter(name => name);

        selectedContainer.innerHTML = `<strong>${messages.selectedLabel}</strong> `;
        selectedListSpan.textContent = names.join(', ');
        selectedContainer.appendChild(selectedListSpan);

    } else {
        selectedContainer.innerHTML = '';
        selectedListSpan.textContent = messages.noneSelectedLabel;
        selectedContainer.appendChild(selectedListSpan);
    }
}