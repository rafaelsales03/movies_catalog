document.addEventListener('turbo:load', initializeTagsInput);
document.addEventListener('DOMContentLoaded', initializeTagsInput);

function initializeTagsInput() {
    const container = document.getElementById('tags-input-container');
    if (!container) return;

    const input = document.getElementById('tag-input');
    const tagsList = document.getElementById('tags-list');
    const hiddenInput = document.getElementById('movie_tag_list');

    if (!input || !tagsList || !hiddenInput) return;

    let tags = [];

    // Quando a página carrega, pega as tags que já estão guardadas em um campo hidden (campo oculto de formulário)
    if (hiddenInput.value) {
        const existingTags = hiddenInput.value.split(',').map(t => t.trim()).filter(t => t);
        tags = [...new Set(existingTags)];
        renderTags();
    }

    // Adiciona tag ao pressionar Enter ou vírgula
    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ',') {
            e.preventDefault();
            addTag();
        }
    });

    // Se o campo tiver algo digitado, ele adiciona como tag automaticamente quando o usuário sai do campo de texto.
    input.addEventListener('blur', () => {
        if (input.value.trim()) {
            addTag();
        }
    });

    // Permite clicar no container para focar o input
    container.addEventListener('click', (e) => {
        if (e.target === container || e.target === tagsList) {
            input.focus();
        }
    });

    function addTag() {
        const tagName = input.value.trim();

        if (!tagName) return;

        const normalizedTag = normalizeTagName(tagName);

        // aqui valida comprimento
        if (normalizedTag.length < 2) {
            showError('A tag deve ter pelo menos 2 caracteres');
            return;
        }

        if (normalizedTag.length > 50) {
            showError('A tag deve ter no máximo 50 caracteres');
            return;
        }

        // Verifica duplicação
        if (tags.includes(normalizedTag)) {
            showError('Esta tag já foi adicionada');
            input.value = '';
            return;
        }

        // aqui ele limita a quantidade de tags
        if (tags.length >= 20) {
            showError('Você pode adicionar no máximo 20 tags');
            return;
        }

        // Adiciona a tag
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
                <button type="button" class="tag-remove" data-tag="${escapeHtml(tagName)}" aria-label="Remover tag">
                    ×
                </button>
            `;

            const removeBtn = tagBadge.querySelector('.tag-remove');
            removeBtn.addEventListener('click', () => {
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

        counter.textContent = `${count}/${maxTags} tags`;

        counter.classList.remove('warning', 'error');
        if (count >= maxTags) {
            counter.classList.add('error');
        } else if (count >= maxTags * 0.8) {
            counter.classList.add('warning');
        }
    }

    function normalizeTagName(name) {
        return name
            .split(' ')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
            .join(' ');
    }

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function showError(message) {
        const existingError = container.querySelector('.tag-error');
        if (existingError) {
            existingError.remove();
        }

        const errorDiv = document.createElement('div');
        errorDiv.className = 'tag-error alert alert-danger alert-dismissible fade show mt-2';
        errorDiv.style.fontSize = '0.875rem';
        errorDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        `;

        container.parentElement.appendChild(errorDiv);

        setTimeout(() => {
            errorDiv.remove();
        }, 3000);
    }
}