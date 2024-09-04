import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "mainCategory", "subCategory", "orderBy", "productGrid"]
  
  connect() {
    this.setFilters()
    this.search()
  }
  
  search() {
    this.showLoadingSpinner()
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    const requestBody = {
      query: this.queryTarget.value,
      options: this.searchOptions(),
      page: 0,
      per_page: 10
    };

    fetch('/api/v1/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify(requestBody)
    })
    .then(response => response.json())
    .then(data => {
      this.populateProductGrid(data)
    })
    .catch(error => {
      console.error('Error:', error)
      this.showErrorMessage()
    })
  }
  
  searchOptions() {
    const options = {}
    if(this.mainCategoryTarget.value) { 
      options.main_category = this.mainCategoryTarget.value;
    }
    
    if(this.subCategoryTarget.value) { 
      options.sub_category = this.subCategoryTarget.value;
    }
    
    if(this.orderByTarget) { 
      
    }
    return options
  }
  
  showLoadingSpinner() { 
    const fragment = document.createDocumentFragment();
    
    for (let i = 0; i < 8; i++) {
      const loadingItem = document.createElement('div');
      loadingItem.className = 'bg-gray-50 aspect-square p-6 rounded-lg shadow-lg flex items-center justify-center';
      loadingItem.innerHTML = `
        <div class="animate-spin rounded-full h-16 w-16 border-2 border-t-8 border-zinc-400"></div>
      `;
      fragment.appendChild(loadingItem);
    }
    
    this.productGridTarget.appendChild(fragment);
  }
  
  showErrorMessage(message) {
    const errorMessage = document.createElement('div')
    errorMessage.className = "absolute inset-0 flex items-center justify-center"  
    errorMessage.innerHTML =`
      <div class="bg-red-100 text-red-700 p-6 rounded-lg shadow-lg">
        <p>Error: Unable to load products</p>
      </div>`
    
    this.productGridTarget.appendChild(errorMessage)
  }
  
  populateProductGrid(results){
    this.productGridTarget.innerHTML = ''
    results.forEach(result => {
      const gridItem = document.createElement('div')
      gridItem.className = "bg-gray-50 aspect-square p-4 rounded-lg shadow-lg flex items-center justify-center"

      const content = document.createElement('div')
      content.className="p-2 flex flex-col items-center w-fit"
      content.innerHTML = `
        <img src="${result.image}" alt="Product Image" class="w-full h-48 object-cover rounded-md">
        <a href="${result.link}" target="_blank" class="mt-4 text-blue-500 hover:underline text-md font-semibold text-center max-h-12">
        ${result.name}
        </a>
        <p class="mt-2 text-gray-700 text-center font-bold">
          ${result.discount_price}
        </p>
      `
      gridItem.appendChild(content)
      this.productGridTarget.appendChild(gridItem)
    })
  }
}
