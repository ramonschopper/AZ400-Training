using System.Collections.Generic;

namespace BooksSample.Models
{
    public class SearchData
    {
        // The text to search for.
        public string searchText { get; set; }

        // The list of results.
        public List<Book> bookList;
    }
}
