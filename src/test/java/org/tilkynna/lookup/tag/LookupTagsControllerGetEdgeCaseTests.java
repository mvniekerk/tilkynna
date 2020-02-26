/**
 * *************************************************
 * Copyright (c) 2019, Grindrod Bank Limited
 * License MIT: https://opensource.org/licenses/MIT
 * **************************************************
 */
package org.tilkynna.lookup.tag;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.openapitools.model.LookupTag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.domain.Sort.Order;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;
import org.tilkynna.ControllerTestConstants;
import org.tilkynna.report.datasource.DatasourceService;
import org.tilkynna.report.destination.DestinationService;
import org.tilkynna.report.generate.download.DownloadService;

@RunWith(SpringRunner.class)
@WebMvcTest(controllers = LookupsApiController.class)
public class LookupTagsControllerGetEdgeCaseTests {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private LookupTagService lookupTagService;

    @MockBean
    private DatasourceService datasourceService;

    @MockBean
    private DownloadService downloadService;

    @MockBean
    private DestinationService destinationService;

    private final String PAGE_NUMBER_STRING = "1";
    private final String PAGE_SIZE_STRING = "5";

    @Test
    public void givenLookupTags_whenNoTags_thenStatus204AndEmptyArrayBody() throws Exception {
        MockitoAnnotations.initMocks(this);

        // Page request [number: 1, size 5, sort: tag: ASC]
       
        Sort defaultSort = Sort.by(Arrays.asList(new Order(Direction.ASC, "tag")));
        
        final PageRequest pr = PageRequest.of(Integer.parseInt(PAGE_NUMBER_STRING), Integer.parseInt(PAGE_SIZE_STRING), defaultSort);

        List<LookupTag> emptyLookupTags = new ArrayList<LookupTag>();
        Page<LookupTag> tagsPage = new PageImpl<LookupTag>(emptyLookupTags, pr, 0);

        Mockito.when(lookupTagService.findAllDistinctTags(pr)).thenReturn(tagsPage);

        mockMvc.perform(get("/lookups/tags") //
                .param(ControllerTestConstants.REQUEST_PARAM_PAGE_NUMBER, PAGE_NUMBER_STRING) //
                .param(ControllerTestConstants.REQUEST_PARAM_PAGE_SIZE, PAGE_SIZE_STRING) //
                .contentType(MediaType.APPLICATION_JSON)) //
                .andExpect(status().is2xxSuccessful()) //
                .andExpect(status().isNoContent()) //
                .andExpect(jsonPath("$", hasSize(0)))//
                .andExpect(header().string(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON + ";charset=UTF-8")) //
                .andDo(MockMvcResultHandlers.print());
    }
}
