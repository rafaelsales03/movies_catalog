document.addEventListener('turbo:load', initializePosterPreview);
document.addEventListener('DOMContentLoaded', initializePosterPreview);

function initializePosterPreview() {
    const posterInput = document.getElementById('poster_input');
    const posterPreviewDiv = document.getElementById('poster_preview');
    const posterPreviewImage = document.getElementById('poster_preview_image');
    const removePosterCheckbox = document.getElementById('remove_poster_checkbox');
    const hiddenRemoveInput = document.getElementById('hidden_remove_poster');

    // Se não encontrar o input de poster, sai da função
    if (!posterInput || !posterPreviewDiv || !posterPreviewImage) {
        return;
    }

    // Lê as mensagens de erro dos atributos
    const invalidFormatMessage = posterInput.dataset.invalidFormatMessage || 'Invalid format.';
    const sizeLimitMessage = posterInput.dataset.sizeLimitMessage || 'Image too large.';
    const loadErrorMessage = posterInput.dataset.loadErrorMessage || 'Error loading image.';


    posterInput.addEventListener('change', function (e) {
        const file = e.target.files[0];

        if (!file) {
            hidePosterPreview();
            return;
        }

        const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/webp'];
        if (!validTypes.includes(file.type)) {
            showError(invalidFormatMessage);
            posterInput.value = ''
            hidePosterPreview();
            return;
        }

        const maxSize = 5 * 1024 * 1024;
        if (file.size > maxSize) {
            showError(sizeLimitMessage);
            posterInput.value = ''
            hidePosterPreview();
            return;
        }

        const reader = new FileReader();

        reader.onload = function (event) {
            posterPreviewImage.src = event.target.result;
            posterPreviewDiv.style.display = 'block';

            // Se existir o checkbox de remoção, desmarca ele
            if (removePosterCheckbox) {
                removePosterCheckbox.checked = false;
                // Garante que o input hidden correspondente seja atualizado para '0'
                if (hiddenRemoveInput) {
                    hiddenRemoveInput.value = '0';
                }
            }
        };

        reader.onerror = function () {
            showError(loadErrorMessage);
            hidePosterPreview();
        };

        reader.readAsURL(file);
    });

    // Atualiza o input hidden quando o checkbox muda
    if (removePosterCheckbox && hiddenRemoveInput) {
        removePosterCheckbox.addEventListener('change', function () {
            hiddenRemoveInput.value = this.checked ? '1' : '0';

            // Se marcou para remover, limpa o input de arquivo e esconde o preview
            if (this.checked) {
                posterInput.value = '';
                hidePosterPreview();
            }
        });
        // Sincroniza o valor inicial do hidden input com o checkbox (caso a página recarregue com erro)
        hiddenRemoveInput.value = removePosterCheckbox.checked ? '1' : '0';
    }
}

// Função para esconder a área de preview
function hidePosterPreview() {
    const posterPreviewDiv = document.getElementById('poster_preview');
    const posterPreviewImage = document.getElementById('poster_preview_image');

    if (posterPreviewDiv) {
        posterPreviewDiv.style.display = 'none';
    }
    if (posterPreviewImage) {
        posterPreviewImage.src = '';
    }
}


// Função para mostrar mensagens de erro perto do input de poster
function showError(message) {
    const posterInput = document.getElementById('poster_input');
    if (!posterInput || !posterInput.parentElement) return;

    const errorContainer = posterInput.parentElement;

    const existingError = errorContainer.querySelector('.poster-upload-error');
    if (existingError) {
        existingError.remove();
    }

    // Criar a div de erro
    const errorDiv = document.createElement('div');
    errorDiv.className = 'poster-upload-error alert alert-danger alert-dismissible fade show mt-2';
    errorDiv.style.fontSize = '0.875rem';
    errorDiv.setAttribute('role', 'alert');
    errorDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    `;

    const formText = errorContainer.querySelector('.form-text');
    if (formText && formText.nextSibling) {
        errorContainer.insertBefore(errorDiv, formText.nextSibling);
    } else {
        errorContainer.appendChild(errorDiv);
    }


    // Remover automaticamente após 5 segundos
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
