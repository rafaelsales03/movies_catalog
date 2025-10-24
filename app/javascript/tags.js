document.addEventListener('turbo:load', initializeTagsInput);
document.addEventListener('DOMContentLoaded', initializeTagsInput);

function initializeTagsInput() {
    const container = document.getElementById('tags-input-container');
    if (!container) return;

    const input = document.getElementById('tag-input');
    const tagsList = document.getElementById('tags-list');
    const hiddenInput = document.getElementById('movie_tag_list');

    if (!input || !tagsList || !hiddenInput) return;

    // --- Ler mensagens traduzidas dos data attributes ---
    const messages = {
        tagTooShort: input.dataset.tagTooShortMessage || 'Tag must be at least 2 characters',
        tagTooLong: input.dataset.tagTooLongMessage || 'Tag must be at most 50 characters',
        tagDuplicate: input.dataset.tagDuplicateMessage || 'This tag has already been added',
        tagLimitReached: input.dataset.tagLimitReachedMessage || 'You can add a maximum of 20 tags',
        ariaRemoveLabel: input.dataset.ariaRemoveLabel || 'Remove tag'
    };

    let tags = [];

    if (hiddenInput.value) {
        const existingTags = hiddenInput.value.split(',').map(t => t.trim()).filter(t => t);
        tags = [...new Set(existingTags)];
        renderTags();
    }

    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ',') {
            e.preventDefault();
            addTag();
        }
    });

    input.addEventListener('blur', () => {
        // Adiciona a tag se houver algo no input, mesmo que não seja Enter/vírgula
        if (input.value.trim()) {
            addTag();
        }
    });

    container.addEventListener('click', (e) => {
        if (e.target === container || e.target === tagsList) {
            input.focus();
        }
    });

    function addTag() {
        const tagName = input.value.trim();
        if (!tagName) return;

        const normalizedTag = normalizeTagName(tagName);

        if (normalizedTag.length < 2) {
            showError(messages.tagTooShort);
            return;
        }

        if (normalizedTag.length > 50) {
            showError(messages.tagTooLong);
            return;
        }

        if (tags.some(t => t.toLowerCase() === normalizedTag.toLowerCase())) {
            showError(messages.tagDuplicate);
            input.value = '';
            return;
        }

        if (tags.length >= 20) {
            showError(messages.tagLimitReached);
            return;
        }

        tags.push(normalizedTag);
        input.value = '';
        renderTags();
        updateHiddenInput();
    }

    function removeTag(tagName) {
        tags = tags.filter(t => t !== tagName);
        renderTags();
        updateHiddenInput();
    }

    function renderTags() {
        tagsList.innerHTML = '';
        tags.forEach(tagName => {
            const tagBadge = document.createElement('span');
            tagBadge.className = 'tag-badge';
            tagBadge.innerHTML = `
                <span>${escapeHtml(tagName)}</span>
                <button type="button" class="tag-remove" data-tag="${escapeHtml(tagName)}" aria-label="${messages.ariaRemoveLabel}">
                    ×
                </button>
            `;

            const removeBtn = tagBadge.querySelector('.tag-remove');
            removeBtn.addEventListener('click', (e) => {
                e.stopPropagation(); // Impede que o clique no botão foque o input
                removeTag(tagName);
            });

            tagsList.appendChild(tagBadge);
        });
        updateCounter();
    }

    function updateHiddenInput() {
        hiddenInput.value = tags.join(', ');
    }

    function updateCounter() {
        const counter = document.getElementById('tags-counter');
        if (!counter) return;

        const count = tags.length;
        const maxTags = 20;

        const counterFormat = counter.dataset.counterFormat || '%{count}/%{max} tags';
        counter.textContent = counterFormat.replace('%{count}', count).replace('%{max}', maxTags);


        counter.classList.remove('warning', 'error');
        if (count >= maxTags) {
            counter.classList.add('error');
        } else if (count >= maxTags * 0.8) {
            counter.classList.add('warning');
        }
    }

    function normalizeTagName(name) {
        // Capitaliza a primeira letra de cada palavra
        return name
            .toLowerCase() // Primeiro tudo minúsculo para consistência
            .split(/[\s,]+/) // Divide por espaço ou vírgula
            .filter(word => word.length > 0)
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
    }

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function showError(message) {
        const containerParent = container.parentElement;
        if (!containerParent) return;

        const existingError = containerParent.querySelector('.tag-error');
        if (existingError) {
            existingError.remove();
        }

        const errorDiv = document.createElement('div');
        errorDiv.className = 'tag-error alert alert-danger alert-dismissible fade show mt-2';
        errorDiv.style.fontSize = '0.875rem';
        errorDiv.setAttribute('role', 'alert');
        const closeButtonLabel = container.dataset.closeLabel || 'Close';
        errorDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="${closeButtonLabel}"></button>
        `;

        // Insere o erro logo após o container de input de tags
        container.insertAdjacentElement('afterend', errorDiv);


        setTimeout(() => {
            if (errorDiv) {
                errorDiv.style.transition = 'opacity 0.5s ease';
                errorDiv.style.opacity = '0';
                setTimeout(() => {
                    errorDiv.remove();
                }, 500);
            }
        }, 5000);
    }

    updateCounter();
}