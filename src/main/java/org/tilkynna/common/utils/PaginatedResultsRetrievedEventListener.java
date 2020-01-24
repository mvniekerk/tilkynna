/**
 * *************************************************
 * Copyright (c) 2019, Grindrod Bank Limited
 * License MIT: https://opensource.org/licenses/MIT
 * **************************************************
 */
package org.tilkynna.common.utils;

import org.openapitools.model.PaginationHeaderResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

/**
 * This class is based a lot on the following examples:
 * 
 * https://gist.github.com/eugenp/1622997 & https://dzone.com/articles/rest-pagination-spring <br>
 * https://www.novatec-gmbh.de/en/page-links-hateoas-spring-boot/ <br>
 * https://www.baeldung.com/spring-events
 * 
 * @author melissap
 *
 */
@Slf4j
@Component
public class PaginatedResultsRetrievedEventListener implements ApplicationListener<PaginatedResultsRetrievedEvent> {

    public static final String PAGINATION_HEADER_NAME = "X-Pagination";

    @Autowired
    protected ObjectMapper objectMapper;

    public PaginatedResultsRetrievedEventListener() {
        super();
    }

    @Override
    public void onApplicationEvent(PaginatedResultsRetrievedEvent event) {
        HttpHeaders headers = event.getHeaders();

        Page tagsPage = event.getPage();

        // get the base URL
        UriComponentsBuilder original = ServletUriComponentsBuilder.fromCurrentRequest();

        PaginationHeaderResponse pageResponse = new PaginationHeaderResponse();
        pageResponse.setTotal(tagsPage.getTotalPages()); // The total number of pages in the resultset
        Long totalElements = Long.valueOf(tagsPage.getTotalElements());
        pageResponse.setCount(totalElements.intValue()); // The total number of results in the resultset
        pageResponse.setSize(tagsPage.getSize()); // The number items to include in a page of results. The page size for the resultset
        pageResponse.setCurrent(tagsPage.getNumber()); // The position of the page in the paged resultset that is being returned

        if (tagsPage.hasNext()) {
            UriComponentsBuilder nextBuilder = replacePageParams(original, tagsPage.nextPageable());
            pageResponse.setNext(nextBuilder.toUriString());
        }

        if (tagsPage.hasPrevious()) {
            UriComponentsBuilder prevBuilder = replacePageParams(original, tagsPage.previousPageable());
            pageResponse.setPrev(prevBuilder.toUriString());
        }

        UriComponentsBuilder firstBuilder = replacePageParams(original, PageRequest.of(0, tagsPage.getSize()));
        pageResponse.setFirst(firstBuilder.toUriString());

        
        UriComponentsBuilder lastBuilder = replacePageParams(original, PageRequest.of(tagsPage.getTotalPages() - 1, tagsPage.getSize()));
        pageResponse.setLast(lastBuilder.toUriString());

        try {
            headers.add(PAGINATION_HEADER_NAME, objectMapper.writeValueAsString(pageResponse));
        } catch (JsonProcessingException e) {
            log.error(e.getMessage());
        }

    }

    private UriComponentsBuilder replacePageParams(UriComponentsBuilder origional, Pageable pageable) {
        UriComponentsBuilder builder = origional.cloneBuilder();
        builder.replaceQueryParam("page", pageable.getPageNumber());
        builder.replaceQueryParam("size", pageable.getPageSize());
        return builder;
    }
}
